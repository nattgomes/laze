package main

import (
	"bufio"
	"database/sql"
	"fmt"
	"log"
	"net/url"
	"os"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
	"time"

	"github.com/tkanos/gonfig"

	"github.com/goware/urlx"
	_ "github.com/lib/pq"
)

type Configuration struct {
	Host     string
	Port     int64
	User     string
	Password string
	Dbname   string
}

type logLine struct {
	timestamp     time.Time
	duration      int64
	clientAdr     string
	resultCode    string
	bytes         int64
	method        string
	url           url.URL
	user          string
	hierarchyCode string
	contentType   string
}

func parseLine(text string) (line logLine, errParse error) {
	splittedString := strings.Split(text, " ")

	splittedTime := strings.Split(splittedString[0], ".")
	unixTime, _ := strconv.ParseInt(splittedTime[0], 10, 64)
	nsec, _ := strconv.ParseInt(splittedTime[1], 10, 64)

	line.timestamp = time.Unix(unixTime, nsec)

	line.duration, _ = strconv.ParseInt(splittedString[1], 10, 64)
	line.clientAdr = splittedString[2]
	line.resultCode = splittedString[3]
	line.bytes, _ = strconv.ParseInt(splittedString[4], 10, 64)
	line.method = splittedString[5]
	parsingURL, err := urlx.Parse(splittedString[6])
	if err != nil {
		errParse = err
		return
	}
	line.url = *parsingURL
	line.user = splittedString[7]
	line.hierarchyCode = splittedString[8]
	line.contentType = splittedString[9]

	return
}

func saveOnDatabase(tx *sql.Tx, line logLine, ch chan<- sql.Result) {
	result, err := tx.Exec("SELECT feed_tables($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14);", line.timestamp.Format("2006-01-02"),
		line.timestamp.Format("15:04:05"), line.contentType, line.user, line.hierarchyCode, line.url.Host, line.resultCode, line.method,
		line.clientAdr, line.duration, line.bytes, line.url.Scheme, line.url.Path, line.url.RawQuery)

	if err != nil {
		fmt.Println(err)
	} else {
		ch <- result
	}
}

func parallel(text string, tx *sql.Tx, count *int, ch chan<- sql.Result) {
	line := regexp.MustCompile(`\s+`).ReplaceAllString(text, " ")
	values, err := parseLine(line)
	if err != nil {
		return
	}

	go saveOnDatabase(tx, values, ch)
	if err == nil {
		*count++
	}
}

func main() {
	start := time.Now()
	configuration := Configuration{}
	dir, _ := filepath.Abs(filepath.Dir(os.Args[0]))
	gonfig.GetConf(dir+"/laze.json", &configuration)
	psqlInfo := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=disable", configuration.Host, configuration.Port, configuration.User, configuration.Password, configuration.Dbname)
	db, err := sql.Open("postgres", psqlInfo)
	if err != nil {
		panic(err)
	}
	defer db.Close()

	if os.Args[1] == "" {
		panic("Input file is missing.")
	}

	file, err := os.Open(os.Args[1])
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	ch := make(chan sql.Result, 32)
	tx, _ := db.Begin()
	count := 0
	for scanner.Scan() {
		go parallel(scanner.Text(), tx, &count, ch)
		if count%cap(ch) == 0 {
			for i := 0; i < cap(ch); i++ {
				<-ch
			}
			fmt.Println("Add line:", count)
			tx.Commit()
			tx, _ = db.Begin()
		}
	}
	for i := 0; i < count%cap(ch); i++ {
		<-ch
	}
	tx.Commit()
	fmt.Println("Add", count, "lines.")
	fmt.Println(time.Now().Sub(start))
}


f = open("/Users/natt/Desktop/access-15-06-18.log", mode='r', encoding='iso-8859-1')

fileToSplit = f.readlines()
print ("Name: " + f.name)

newLog = open("/Users/natt/Desktop/new2.log","a+")

count = 0

for line in fileToSplit:
    if count%5000==0:
        newLog.write(line)
    count = count+1
    print (count)

newLog.close()


# "_id" : "natt",
# 	"first_name" : "Natt",
# 	"last_name" : "Gomes",
# 	"cpf" : "01330694007",
# 	"phone" : "9999999999",
# 	"password" : "469eca6adf0222db6229fd08d15d10fb64bda07b37b9e848ec7edb4e497f92a4,eCNdv",
# 	"email" : "natt@natt.com"

import time, datetime
import sys
from tempfile import NamedTemporaryFile
import os
import csv
from tempfile import NamedTemporaryFile

f = open("app/files/access_new.log", mode='r', encoding="ISO-8859-1")
# f = open("app/files/access_new.log", mode='r')
fileToChange = f.readlines()

with NamedTemporaryFile(dir="app/files",delete=False) as temp:

    file = ""
    for row in fileToChange:
        pieces = row.split()
        var_datetime = datetime.datetime.fromtimestamp(float(pieces[0]))
        pieces[0] = (var_datetime + datetime.timedelta(days=563)).strftime('%s.%f')[:-3]

        line = " ".join(pieces)
        file += line + "\n"
    file = file[:-1]
    temp.write(file.encode())

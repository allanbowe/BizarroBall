# Bizarro Ball

## What Is It?

This repository contains the sample data used in the seminal book [Data Management Solutions Using SAS Hash Table Operations: A Business Intelligence Case Study](https://www.amazon.com/Management-Solutions-Using-Table-Operations/dp/1629601438) by [Paul Dorfman](https://www.linkedin.com/in/pauldorfman/) and [Don Henderson](https://www.linkedin.com/in/donaldjhenderson/).  More information on the incredible power of hashing can be found in their SGF2017 paper [Beyond Table Lookup: The Versatile SAS® Hash Object ](https://support.sas.com/resources/papers/proceedings17/0821-2017.pdf).


## Who Is It For?
Primarily this data is useful (and was prepared specifically) for readers of the aforementioned [book](https://www.amazon.com/Management-Solutions-Using-Table-Operations/dp/1629601438), however the authors have given permission for the data to be used for other purposes as well - such as testing, education, development, and demos.

Unlike the sample data in SASHELP, the Bizarro data can _modified_.  It also contains some interesting properties (such as md5 hashed indexes / surrogate keys).

## How Do I Use It?

For ease of extraction, the files are built into a single [bizarroball.sas](bizarroball.sas) file that can be easily copy pasted into a SAS session.

Simply modify the `root` variable (to a permanent path, if desired), and hit RUN.

## This Is Great!  How Do I Show My Appreciation?

After you have bought the book, feel free to hit the STAR button at the top of this repo so others can learn about (and benefit from) this contribution
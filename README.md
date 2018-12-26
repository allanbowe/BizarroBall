# Bizarro Ball

## What is it?

This repository contains the sample data used in the seminal book [Data Management Solutions Using SAS Hash Table Operations: A Business Intelligence Case Study](https://www.amazon.com/Management-Solutions-Using-Table-Operations/dp/1629601438) by [Paul Dorfman](https://www.linkedin.com/in/pauldorfman/) and [Don Henderson](https://www.linkedin.com/in/donaldjhenderson/).  More information on the incredible power of hashing can be found in their SGF2017 paper [Beyond Table Lookup: The Versatile SAS® Hash Object ](https://support.sas.com/resources/papers/proceedings17/0821-2017.pdf).


# Who is it for?
Primarily this data is useful (and was prepared specifically) for readers of the aforementioned book, however the authors have given permission for the data to be used for other purposes as well - such as testing, education, development, and demos.

Unlike the sample data in SASHELP, the Bizarro data can _modified_.  It also contains some interesting properties (such as md5 hashed indexes / surrogate keys).

# How do I use it?

For ease of extraction, the files are built into a single [bizarroball.sas](bizzarroball.sas) file that can be easily copy pasted into a SAS session.

Simply modify the `root` variable (to a permanent path, if desired), and hit RUN.

# This is great!  How do I show my gratitude?

After you have bought the book, feel free to hit the STAR button on this repo so others can learn about (and benefit from) this work!
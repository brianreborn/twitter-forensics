These tools are sufficient for the following:
 1. inspector.sh <username>
  a. retrieves Twitter account metadata using the twscrape Python package
  b. data is retrieved into <current working directory>/@<username>
  c. the file format is {user,followers,following}.json where each one is a series of newline-separated JSON objects
 2. gephi-ingest.py <directory>
  a. initializes or updates the <directory>/twitter_data.db SQLite3 database
  b. establishes and populates Users and Followers tables
 3. gephi-digest
  a. updates the <current working directory>/twitter_data.db SQLite3 database
  b. establishes and populates Nodes and Edges tables that Gephi can directly accept as input via database import functionality

The basic requirements are Python3 and the twscrape package. The thread-count is currently just hard-coded to 4 because that's what my laptop has and @grok is bad at coding.

My own setup procedure was something like:
 $ mkdir twitter-forensics && cd twitter-forensics
 $ python3 -m venv venv
 $ . venv/bin/activate
 (venv) $ pip3 install twscrape
  (Here you need to perform the twscrape setup process for the Twitter accounts you will use to retrieve data with.)
 (venv) $ for i in account1 account2; do ./inspector.sh $i; done
 (venv) $ mkdir \#subset && cd \#subset
 (venv) $ ln -s ../venv
 (venv) $ ln -s ../@account1
 (venv) $ ./gephi-ingest.py .
 (venv) $ ./gephi-digest.py
At the end of this, you should have a twitter_data.db SQLite3 file which Gephi can import.

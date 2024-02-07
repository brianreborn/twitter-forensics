# Twitter Forensics Tools

These tools are sufficient for the following:

1.  **Inspector**: Retrieves Twitter account metadata using the twscrape Python package. Data is retrieved into `current working directory/username` in the format `{user, followers, following}.json`, where each file contains a series of newline-separated JSON objects.

    Usage: `inspector.sh <username>`

2.  **Gephi Ingest**: Initializes or updates the `directory/twitter_data.db` SQLite3 database, and populates the Users and Followers tables.

    Usage: `gephi-ingest.py <directory>`

3.  **Gephi Digest**: Updates the `current working directory/twitter_data.db` SQLite3 database, and populates the Nodes and Edges tables that Gephi can directly accept as input via database import functionality.

    Usage: `gephi-digest`

## Requirements

* Python 3
* twscrape package

## Setup

1.  Create a new directory and navigate to it:
    ```bash
    $ mkdir twitter-forensics && cd twitter-forensics
    ```
2.  Create a virtual environment and activate it:
    ```bash
    $ python3 -m venv venv
    $ . venv/bin/activate
    ```
3.  Install twscrape:
    ```bash
    (venv) $ pip3 install twscrape
    ```
    Follow the twscrape setup process for the Twitter accounts you will use to retrieve data with.
4.  Run the inspector script for the desired accounts:
    ```bash
    (venv) $ for i in account1 account2; do ./inspector.sh $i; done
    ```
5.  Create a new directory for a subset of data and navigate to it:
    ```bash
    (venv) $ mkdir \#subset && cd \#subset
    ```
6.  Create symbolic links to the virtual environment and the account data:
    ```bash
    (venv) $ ln -s ../venv
    (venv) $ ln -s ../@account1
    ```
7.  Run the Gephi ingest and digest scripts:
    ```bash
    (venv) $ ./gephi-ingest.py .
    (venv) $ ./gephi-digest.py
    ```
    At the end of this process, you should have a `twitter_data.db` SQLite3 file that Gephi can import.

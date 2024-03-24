#!/bin/sh
# Usage: add-account.txt 'username:password:[email]:[email_password]'
echo "$@" >> accounts.txt
twscrape add_accounts accounts.txt username:password:email:email_password
twscrape accounts
twscrape --debug login_accounts --manual

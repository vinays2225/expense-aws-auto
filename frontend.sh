#!/bin/bash

 source ./common.sh

app_name=ngnix

 check_root

insatll_nginx

system_setup


rm -rf /usr/share/nginx/html/*
validate $? "remove default content"

curl -L -o /tmp/frontend.tar.gz https://raw.githubusercontent.com/daws-92s/expense-documentation/refs/heads/main/artifacts/expense-frontend-v5.tar.gz &>> $logs_file
validate $? "downloading code"

cd /usr/share/nginx/html
tar -xzf /tmp/frontend.tar.gz
validate $? "unzipping code"

# /etc/nginx/default.d/expense.conf

 frontend_conf


restart

total_time



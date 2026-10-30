#!/bin/bash

 
source ./common.sh

app_name="backend"

check_root

install_nodejs

app_setup

npm install &>> $logs_file
validate $? "Installing dependencies"

#/etc/systemd/system/backend.service

sed -i "s/DOMAIN_NAME/$domain_name/g" "$scripts_dir/$(app_name).service"
cp "$scripts_dir/$(app_name).service" /etc/systemd/system/$(app_name).service
validate $? "copy $(app_name) service"

system_setup

mysql_client

mysql -h mysql.$domain_name -u root -pExpenseApp@1 < /app/schema/backend.sql
validate $? "load schema"


restart

total_time

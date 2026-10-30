#!/bin/bash
# Common configuration

user_id=$(id -u)
logs_folder="/var/log/roboshop"
logs_file="${logs_folder}/${0}.log"
scripts_dir=$(dirname "$(realpath "$0")")
domain_name="yanvisol.online"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


check_root(){
    if [ $user_id -ne 0 ]; then
        echo "Please run this script with sudo access.."
        exit 1
    fi
}

timestamp(){
    date "+%F %T" 
}

mkdir -p $logs_folder
echo -e "$(timestamp) [INFO] ==== Script started Execution =====" | tee -a $logs_file

validate(){
    if [ $1 -ne 0 ]; then
        echo -e "$(timestamp) [ERROR] ${2}..${R}FAILED${N}" | tee -a $logs_file
        exit 1
    else
        echo -e "$(timestamp) [INFO] ${2}..${G}SUCCESS${N}" | tee -a $logs_file
    fi
}



install_nodejs(){
    dnf module disable nodejs -y
    dnf module enable nodejs:24 -y
    dnf install nodejs -y
    validate $? "Installing nodejs 24"

    
}


insatll_nginx(){
    dnf install nginx -y
    validate $? "Installing nginx"
}

frontend_conf(){
#/etc/nginx/default.d/expense.conf
 sed -e "s/DOMAIN_NAME/${domain_name}/g" "$scripts_dir/expense.conf"
 cp "$scripts_dir/expense.conf" /etc/nginx/default.d/expense.conf
 validate $? "Copy conf file"
}

lb_nginx(){

    rm -f /etc/nginx/nginx.conf
   # cd /etc/nginx

    sed -e "s/DOMAIN_NAME/${domain_name}/g" "$scripts_dir/lb.conf"
    cp "$scripts_dir/lb.conf" /etc/nginx/nginx.conf
    validate $? "Copy conf file"
}

app_setup(){

    id expense &>> $logs_file
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "expense system user" expense &>> $logs_file
        validate $? "Creating system user"
    else
        echo -e "$(timestamp) [INFO] System user roboshop already exist...${Y}SKIPPING${N}"
    fi

    rm -rf /app
    validate $? "Removing old code"

    mkdir -p /app
    validate $? "Creating app directory"
    curl -L -o "/tmp/$app_name.zip" "https://raw.githubusercontent.com/daws-92s/expense-documentation/refs/heads/main/artifacts/expense-'${app_name}'-v5.zip" &>> $logs_file
    validate $? "Downloading $app_name"

    cd /app
    unzip "/tmp/$app_name.zip" &>> $logs_file
    validate $? "Unzipping $app_name"
}

system_setup(){

    systemctl daemon-reload &>> $logs_file
    systemctl enable $app_name &>> $logs_file
    systemctl start $app_name &>> $logs_file
    validate $? "Starting and enabling $app_name"
}

restart(){
    systemctl restart $app_name
    validate $? "Restarting $app_name"
}

total_time(){
    echo -e "$(timestamp) [INFO] Script completed in $SECONDS seconds" | tee -a $logs_file
    echo -e "$(timestamp) [INFO] ==== Script completed Execution =====" | tee -a $logs_file    
}

mysql_client(){
    dnf install mysql -y
}
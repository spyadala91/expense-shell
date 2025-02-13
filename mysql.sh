#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/expense-logs"
LOG_FILE=$(basename "$0" | cut -d "." -f1 )
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

# Ensure log directory exists
mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R failure $N"
        exit 1
    else
        echo -e "$2 ... $G success $N"
    fi 
}

CHECK_POINT(){
    if [ $USERID -ne 0 ]; then
        echo -e "$R ERROR:: You must have sudo access to execute this script $N"
        exit 1
    fi
}

echo "Script started executing at: $TIMESTAMP" | tee -a $LOG_FILE_NAME

CHECK_POINT

dnf install mysql-server -y &>> $LOG_FILE_NAME
VALIDATE $? "Installing MySQL Server"

systemctl daemon-reload &>> $LOG_FILE_NAME
VALIDATE $? "Reloading MySQL Server"

systemctl enable mysql &>> $LOG_FILE_NAME
VALIDATE $? "Enabling MySQL Server"

systemctl start mysqld &>> $LOG_FILE_NAME
VALIDATE $? "Starting MySQL Server"

mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'ExpenseApp@1';" &>> $LOG_FILE_NAME
VALIDATE $? "Setting Root Password"

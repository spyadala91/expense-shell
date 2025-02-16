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
        echo "ERROR:: You must have sudo access to execute this script"
        exit 1
    fi
}

echo "Script started executing at: $TIMESTAMP" &>> $LOG_FILE_NAME

CHECK_POINT

dnf install mysql-server -y
VALIDATE $? "Installing MySQL Server" &>> $LOG_FILE_NAME

systemctl enable mysqld &>> $LOG_FILE_NAME
VALIDATE $? "Enabling MySQL Server"

systemctl start mysqld &>> $LOG_FILE_NAME
VALIDATE $? "Starting MySQL Server"

mysql -h mysql.yadala.fun -u root -pExpenseApp@1 -e 'show databases;'

if [ $? -ne 0 ]
then
    echo "Mysql Root password not setup" &>> $LOG_FILE_NAME
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "Setting Root Password"
else 
    echo "Mysql root password already setup ... Skipping"
fi
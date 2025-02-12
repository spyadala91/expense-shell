#!/bin/bash

USERID=$(id -u)
    R="\e[31m"
    G="\e[32m"
    Y="\e[33m"
    LOGS_FOLDER="var/log/expense-logs"
    LOG_FILE=$(echo $0 | cut -d "." -f1 )
    TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
    LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"


VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 .. $R failure"
        exit 1
    else
        echo -e "$2.. $G sucess"
    fi 
  
}

CHECK_POINT(){
    if [ $1 -ne 0 ]
    then
       echo "ERROR:: You must have sudo access to execute this script"
       exit 1 #other thank 0
    fi
}       
echo "Script started executing at: $TIMESTAMP"

CHECK_POINT

dnf install mysql-server -y
VALIDATE $? "Installing mysql server"

systemctl enable mysql
VALIDATE $? "Enabling mysql server"

systemctl start mysqld
VALIDATE $? "starting mysql server"

mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE $? "Setting Root Password"
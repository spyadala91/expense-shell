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

dnf module disable nodejs -y &>> $LOG_FILE_NAME
VALIDATE $? "Disabling existing default NodeJS"

dnf module enable nodejs:20 -y &>> $LOG_FILE_NAME
VALIDATE $? "Enabling NodeJS 20"

dnf install nodejs -y &>> $LOG_FILE_NAME
VALIDATE $? "Installing NodeJS"

id expense &>> $LOG_FILE_NAME
if [ £? -ne 0 ]
then
   useradd expense &>> $LOG_FILE_NAME
   VALIDATE $? "Adding expense user"
else
   echo -e "expense user already exists ... skipping"
fi   

mkdir -p /app &>> $LOG_FILE_NAME
VALIDATE $? "Creating a directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>> $LOG_FILE_NAME
VALIDATE $? "Downloading backend"

cd /app
rm -rf /app/*

unzip /tmp/backend.zip &>> $LOG_FILE_NAME
VALIDATE $? "Unzip backend"

npm install &>> $LOG_FILE_NAME
VALIDATE $? "Installing dependencies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service

#prepare MySQL Schema

dnf install mysql -y &>> $LOG_FILE_NAME
VALIDATE $? "Installing MySQL Client"

mysql -h mysql.yadala.fun -uroot -pExpenseApp@1 < /app/schema/backend.sql &>> $LOG_FILE_NAME
VALIDATE $? "Setting up the schema and tables"

systemctl daemon-reload &>> $LOG_FILE_NAME
VALIDATE $? "Demon Reload"

systemctl enable backend &>> $LOG_FILE_NAME
VALIDATE $? "Enabling backend"

systemctl restart backend &>> $LOG_FILE_NAME
VALIDATE $? "Starting Backend"
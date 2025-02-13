    #!/bin/bash

    USERID=$(id -u)
    R="\e[31m"
    G="\e[32m"
    Y="\e[33m"
    N="\e[0m"

    LOGS_FOLDER="var/log/expense-logs"
    LOG_FILE=$(echo $0 | cut -d "." -f1 )
    TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
    LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

    VALIDATE(){
        if [ $1 -ne 0 ]
        then
           echo -e "$2 ... $R failure $N"
           exit 1
        else
        echo -e "$2 ... $G sucess $N"
        fi 
    }

    CHECK_POINT(){
        if [ $USERID -ne 0 ]
        then
            echo "ERROR:: You must have sudo access to execute this script"
            exit 1 #other than 0
        fi
}

    echo "Script started executing at: $TIMESTAMP"

    CHECK_POINT

    dnf install mysql-server -y
    VALIDATE $? "Installing MySQL Server"

    systemctl enable mysql
    VALIDATE $? "Enabling MySQL Server"

    systemctl start mysqld
    VALIDATE $? "starting MySQL Server"

    mysql -h mysql.yadala.fun -u root -pExpenseApp@1 -e 'show databases;'
    VALIDATE $? "Setting Root Password"

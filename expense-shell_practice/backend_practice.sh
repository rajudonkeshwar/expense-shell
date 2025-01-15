#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/expense-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1 )
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo "ERROR:: You must have sudo access to execute this script"
        exit 1 #other than 0
    fi
}

echo "Script started executing at: $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT

dnf module disable nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Disabling existing default NodeJS"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
VALIDATE $? "enabling nodejs:20"

dnf install nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "installing node js"

useradd expense &>>$LOG_FILE_NAME
VALIDATE $? "adding of expense user"

mkdir -p /app &>>$LOG_FILE_NAME
VALIDATE $? " creating app/ directory"


curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? " downlaoding backend-v2.zip file "

cd /app &>>$LOG_FILE_NAME
VALIDATE $? " redirecting app folder "

unzip /tmp/backend.zip &>>$LOG_FILE_NAME
VALIDATE $? " unzipping the backend.zip "

npm install &>>$LOG_FILE_NAME
VALIDATE $? " running npm command  "

cp  /opt/expense-shell/expense-shell_practice/back_end.service  /etc/systemd/system/backend.service &>>$LOG_FILE_NAME
VALIDATE $? " coping the backend.service file  "


systemctl daemon-reload &>>$LOG_FILE_NAME
VALIDATE $? " reloading the daemon-reload  "


dnf install mysql -y &>>$LOG_FILE_NAME
VALIDATE $? " installing mysql "


mysql -h mysql.vijaychandra.site -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE_NAME
VALIDATE $? " loading schema "

systemctl restart backend &>>$LOG_FILE_NAME
VALIDATE $? " restarting the backend "


systemctl enable backend &>>$LOG_FILE_NAME
VALIDATE $? " enabling the backend "








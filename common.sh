script_location=$(pwd)
LOG=/tmp/roboshop.log

print_head(){
  echo -e "\e[1;32m $1 \e[0m"
}
status_check(){
  if[$? -eq 0 ]
  then
    echo "SUCCESS"
  else
    echo "FAILURE"
    echo "refer failure log information LOG- ${LOG}"
    exit
  fi
}
NODEJS(){
print_head "setup nodejs repos"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> ${LOG}
status_check

print_head "install nodejs"
yum install nodejs -y &>> ${LOG}
status_check

APP_PREREQ

print_head "install app dependencies"
npm install &>> ${LOG}
status_check

SYSTEMD_SETUP

SCHEMA_LOAD
}

APP_PREREQ(){
  print_head "add application user"
  id roboshop
  if[ $? -ne 0 ]
  then
    useradd roboshop
  fi
  status_check

  print_head "create app directory"
  mkdir -p /app
  status_check

  print_head "download app content"
  curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/$component &>> ${LOG}
  status_check

  print_head "remove old app content"
  rm -rm /app/*
  status_check

  print_head "extract app content"
  cd /app
  unzip /tmp/${component}.zip  &>> ${LOG}
  status_check
}

SYSTEMD_SETUP(){
  print_head "load systemd file"
  cp ${script_location}/files/${component}.service /etc/systemd/system/${component}.service
  status_check

  print_head "load systemd file"
  systemctl daemon-reload
  status_check

  print_head "enable ${component}"
  systemctl enable ${component} &>> ${LOG}
  status_check

  print_head "start ${component}"
  systemctl start ${component}
  status_check
}

SCHEMA_LOAD(){
  if[ ${schema_load} == "true"]
  then
    print_head "loading mongodb repo file"
    cp ${script_location}/files/mongodb.repo /etc/yum.repos.d/mongodb.repo
    status_check

    print_head "installing mongodb-org-shell"
    yum install mongodb-org-shell &>> ${LOG}
    status_check

    print_head "loading mongodb schema"
    mongo --host MONGODB-SERVER-IPADDRESS </app/schema/${component}.js &>> ${LOG}
    status_check
  fi
}



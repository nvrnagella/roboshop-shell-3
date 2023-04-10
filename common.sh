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


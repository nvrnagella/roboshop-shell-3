source common.sh

if [ -z "${mysql_root_password}" ]; then
  echo "mysql root password variable missing"
  exit
fi

component=shipping
schema_load=true
schema_type=mysql

MAVEN
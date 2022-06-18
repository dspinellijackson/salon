psql --username=freecodecamp --dbname=postgres

# You should create a database named salon

CREATE DATABASE salon;

# You should connect to your database, then create tables named customers,
appointments, and services

\c salon;

CREATE TABLE customers();
CREATE TABLE appointments();
CREATE TABLE services();

# Each table should have a primary key column that automatically increments
# Each primary key column should follow the naming convention, table_name_id.
For example, the customers table should have a customer_id key. Note that there’s
no s at the end of customer

ALTER TABLE customers ADD COLUMN customer_id SERIAL PRIMARY KEY NOT NULL;
ALTER TABLE appointments ADD COLUMN appointment_id SERIAL PRIMARY KEY NOT NULL;
ALTER TABLE services ADD COLUMN service_id SERIAL PRIMARY KEY NOT NULL;

# Your appointments table should have a customer_id foreign key that references
the customer_id column from the customers table

ALTER TABLE appointments ADD COLUMN customer_id INT NOT NULL;
ALTER TABLE appointments ADD FOREIGN KEY(customer_id) REFERENCES customers(customer_id);

# Your appointments table should have a service_id foreign key that references
the service_id column from the services table

ALTER TABLE appointments ADD COLUMN service_id INT NOT NULL;
ALTER TABLE appointments ADD FOREIGN KEY(service_id) REFERENCES services(service_id);

# Your customers table should have phone that must be unique

ALTER TABLE customers ADD COLUMN phone VARCHAR(20) UNIQUE NOT NULL;

# Your customers and services tables should have a name column

ALTER TABLE customers ADD COLUMN name VARCHAR(30) NOT NULL;
ALTER TABLE services ADD COLUMN name VARCHAR(30) NOT NULL;

# Your appointments table should have a time column

ALTER TABLE appointments ADD COLUMN time TIME NOT NULL;

# You should have at least three rows in your services table for the different
services you offer

INSERT INTO services(name) VALUES('trim');
INSERT INTO services(name) VALUES('cut & wash');
INSERT INTO services(name) VALUES('color');

# You should create a script file named salon.sh in the project folder

touch salon.sh

# Your script file should have a “shebang” that uses bash when the file is
executed (use #! /bin/bash)

#!/bin/bash

# Your script file should have executable permissions

chmod +x salon.sh

# You should not use the clear command in your script

# You should display a numbered list of the services you offer before the first
prompt for input, each with the format #) <service>. For example, 1) cut, where
1 is the service_id

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

MAIN MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\nWelcome to My Salon, how can I help you?\n"
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done
  READ SERVICE_ID_SELECTED

# If you pick a service that doesn't exist, you should be shown the same list of
services again

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else

# Your script should prompt users to enter a service_id, phone number, a name if
they aren’t already a customer, and a time. You should use read to read these
inputs into variables named SERVICE_ID_SELECTED, CUSTOMER_PHONE, CUSTOMER_NAME,
and SERVICE_TIME

    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# If a phone number entered doesn’t exist, you should get the customers name and
enter it and the phone number into the customers table

    if [[ -z CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$PHONE_NUMBER', '$CUSTOMER_NAME')")
    else
    fi

    SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    echo -e "\nWhat time would you like your $SERVICE, $CUSTOMER_NAME?"
    read SERVICE_TIME

  # get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id WHERE phone = CUSTOMER_PHONE")

  # update appointments table
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, $SERVICE_TIME)")

# You can create a row in the appointments table by running your script and
entering 1, 555-555-5555, Fabio, 10:30 at each request for input if that phone
number isn’t in the customers table. The row should have the customer_id for
that customer, and the service_id for the service entered

# You can create another row in the appointments table by running your script
and entering 2, 555-555-5555, 11am at each request for input if that phone number
is already in the customers table. The row should have the customer_id for that
customer, and the service_id for the service entered

# After an appointment is successfully added, you should output the message I
have put you down for a <service> at <time>, <name>. For example, if the user
chooses cut as the service, 10:30 is entered for the time, and their name is
Fabio in the database the output would be I have put your down for a cut at
10:30, Fabio.

    MAIN_MENU "I have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}


##########################################################################################


#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\nWelcome to My Salon, how can I help you?\n"
  SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done
  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-3]$ ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else

    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    SERVICE_FORMATTED=$(echo $SERVICE | sed 's/ //g')
    CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/ //g')

    echo -e "\nWhat time would you like your $SERVICE_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
    read SERVICE_TIME

    # get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # update appointments table
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    echo -e "\nI have put you down for a $SERVICE_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."  

  fi
}

MAIN_MENU
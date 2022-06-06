#! /bin/bash

echo -e "\n~~~~~ MY SALON ~~~~~"

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  # print menu message 
  echo -e "\n$1\n"
  # print services list
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do 
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  # send to appointment menu
  APPOINTMENT
}

APPOINTMENT() {
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services where service_id=$SERVICE_ID_SELECTED")
  # if selected number is not valid
  if [[ -z $SERVICE_NAME ]]
  then
  # send to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # ask for phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    # if number is not registered  
    if [[ -z $CUSTOMER_NAME ]]
    then
      # ask for customer name
      echo -e "\nT don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      # insert customer
      INSERT_CUTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')") 
    fi
    # ask for appointment time
    echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//')"
    read SERVICE_TIME
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    # insert appointment 
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    # print confirmation message
    echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//')."
  fi
}

MAIN_MENU "Welcome to My Salon, how can I help you?"
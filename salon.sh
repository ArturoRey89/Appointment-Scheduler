#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t -c"

echo -e "\n~~~ Piere's Salon Order Menu~~~\n"

RESERVATION () {
  if [[ $1 ]]
  then
    echo -e "\n$1" 
  fi

  echo -e "\nWelcome! Please select a service"
  #Print MENU
  echo "$($PSQL "SELECT * FROM services")" | while read ID BAR NAME
  do 
    echo "$ID) $NAME"
  done
  read SERVICE_ID_SELECTED

  # Test if input is number 
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    RESERVATION "Please enter a valid number"
  else
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_NAME ]]
    then
      RESERVATION "Please enter a valid number"

    else 
      # GET customer info
      echo -e "\nEnter your phone number(123-456-789):"
      read CUSTOMER_PHONE
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

      # IF new customer  
      if [[ -z $CUSTOMER_ID ]]
      then
        echo "Enter your name:"
        read CUSTOMER_NAME
        INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      else
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      fi

      echo -e "\nType your prefered time for the order:"
      read SERVICE_TIME
      
      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      
      FORMATED_SERVICE_NAME=$(echo $SERVICE_NAME | sed -r 's/^ *| *$//g')
      echo -e "\nI have put you down for a $FORMATED_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}
RESERVATION
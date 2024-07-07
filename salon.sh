#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  SERVICES=$($PSQL "SELECT service_id, name FROM services")

  # Show the menu
  echo "$SERVICES" | while IFS="|" read -r SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED

  # Check if the input is a valid number
  if ! [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
    echo -e "\nInvalid input. Please enter a number."
    MAIN_MENU
    return
  fi

  # Check if the service_id exists
  CHOSEN_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")

  if [[ -z $CHOSEN_NAME ]]; then
    echo -e "\nService not found. Please select a valid service."
    MAIN_MENU
  else
    echo -e "\nYou have selected: $CHOSEN_NAME"
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    EXIST=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $EXIST ]]; then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      $PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')"
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      
      echo -e "\nWhat time would you like your $CHOSEN_NAME, $CUSTOMER_NAME?"
      
      read SERVICE_TIME
      $PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED,'$SERVICE_TIME')"
      echo -e "\nI have put you down for a $CHOSEN_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    else
      echo -e "\nWhat time would you like your $CHOSEN_NAME, $EXIST?"
      read SERVICE_TIME
      echo -e "\nI have put you down for a $CHOSEN_NAME at $SERVICE_TIME, $EXIST."
    fi
  fi
}

MAIN_MENU


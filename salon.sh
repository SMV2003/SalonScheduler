#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU () 
{
    if [[ $1 ]]
    then
        echo -e "\n$1\n"
    fi
    echo -e "Welcome to My Salon how may I help you?\n"
    SERVICES=$($PSQL "SELECT service_id,name FROM services")
    echo "$SERVICES" | while IFS=" " read SERVICE_ID BAR SERVICE
    do
        echo -e "$SERVICE_ID) $SERVICE"
    done
    read SERVICE_ID_SELECTED
}
    
MAIN_MENU
if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
then
    MAIN_MENU "Enter a valid input"
else
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_NAME ]]
    then
        MAIN_MENU "Choose a valid service!"
    fi
    echo -e "\nEnter your phone number:"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]]
    then
        echo I don't have a record for that phone number, what's your name?
        read CUSTOMER_NAME
        CUSTOMER_INSERT_RES=$($PSQL "INSERT INTO customers(phone,name) VALUES ('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
    fi

    echo What time would you like your appointment in military time, $CUSTOMER_NAME?
    read SERVICE_TIME
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    TIME_INSET_RES=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES ($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
    if [[ $TIME_INSET_RES == "INSERT 0 1" ]]
    then
        echo I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.
    fi

fi
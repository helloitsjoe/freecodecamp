#!/bin/bash

echo $($PSQL "truncate appointments, customers")
echo -e "\n~~~~ Salon Services ~~~~\n"

PSQL=$(echo "psql --username=freecodecamp --dbname=salon --tuples-only -c")


MAIN_MENU() {
	if [[ -n $1 ]]; then
		echo -e "\n$1"
	fi
	echo -e "\nPlease choose a service."
	SERVICES=$($PSQL "select service_id, name from services")
	echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
	do
		echo -e "$SERVICE_ID) $SERVICE_NAME"
	done

	read SERVICE_ID_SELECTED
	if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
		MAIN_MENU
	else
		BOOK
	fi
}

BOOK() {
	SERVICE_ID=$($PSQL "select service_id from services where service_id = $SERVICE_ID_SELECTED;")
	if [[ -z $SERVICE_ID ]]; then
		MAIN_MENU
	fi

	echo -e "\nPlease enter your phone number."
	read CUSTOMER_PHONE
	CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE';")
	echo $CUSTOMER_ID

	if [[ -z $CUSTOMER_ID ]]; then
	  echo -e "\nPlease enter your name."
   	  read CUSTOMER_NAME
	  echo $($PSQL "insert into customers(name, phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
	  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE';")
	fi

	echo -e "\nPlease enter your desired appointment time."
	read SERVICE_TIME
	
	if [[ -z $SERVICE_TIME ]]; then
		MAIN_MENU "That is not a valid time."
	fi

	APPOINTMENT_RESULT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

	if [[ -n "$APPOINTMENT_RESULT" ]]; then
		SERVICE_NAME=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED;")
		CUSTOMER_NAME=$($PSQL "select name from customers where customer_id = $CUSTOMER_ID;")

		echo "I have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *//g') at $SERVICE_TIME, $( echo $CUSTOMER_NAME | sed -r 's/^ *//g')."
	fi
}

MAIN_MENU

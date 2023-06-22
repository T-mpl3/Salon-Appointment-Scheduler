#!/bin/bash
echo -e "\n~~~~~ Salon Services ~~~~~~\n"
PSQL='psql -X -qq --username=freecodecamp --dbname=salon --tuples-only -c'
MAIN_MENU() {
	if [[ $1 ]]
	then
		echo -e "\n$1"
	fi
	echo -e "1) cut\n2) wash\n3) style"
	read SERVICE_ID_SELECTED
	SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")

	if [[ $SERVICE_NAME ]]
	then
		echo -e "\nEnter your phone number to continue booking:"
		read CUSTOMER_PHONE
		CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

		if [[ -z $CUSTOMER_ID ]] 
		then
			echo -e "\nYou are not in our system. Please enter your first name:"
			read CUSTOMER_NAME
			$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
			CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
		else
			CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id='$CUSTOMER_ID'")
		fi
		
		echo -e "\nPlease enter the time for your appointment:"
		read SERVICE_TIME
		$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
	else
		MAIN_MENU "Please select the number of a service listed."
	fi
	SERVICE_NAME_CORRECTED=$(echo $SERVICE_NAME | sed -E 's/^ +| +$//g')
	CUSTOMER_NAME_CORRECTED=$(echo $CUSTOMER_NAME | sed -E 's/^ +| +$//g')
	echo -e "\nI have put you down for a $SERVICE_NAME_CORRECTED at $SERVICE_TIME, $CUSTOMER_NAME_CORRECTED.\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
}

MAIN_MENU

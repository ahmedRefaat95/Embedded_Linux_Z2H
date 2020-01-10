#!/bin/bash

#clearing the terminal
clear

#saving the path in which the script exists
FILE="$(pwd)""/phonebook.sh"

#funcion which inserts a new contact in the database
function insert
{	
	#creating an array to keep multiple phone numbers	
	declare -a numbers_array

	echo		
	echo "Adding new contact"
	echo "------------------"
	#Getting the name of the new contact
	read -p "Enter the new contact name: " contact_name

	#checking if the user entered an empty string
	while [[ $contact_name = '' ]] 
	do
	   printf '%s\n' "No contact name entered"
	   read -p "Enter the new contact name: " contact_name
	done
	 
  	#Getting the number of the new contact
	read -p "Enter the new contact number: " contact_number
	
	#checking if the user entered an empty string
	while [[ $contact_number == '' ]] 
	do
	   printf '%s\n' "No contact number entered"
	   read -p "Enter the new contact number: " contact_number
	done
	
	#Asking the user if he/she wants to add another number to the same contact
	read -p "Do you want to enter another number ? (y/n) : " choice

	#checking if the user entered somethig other than 'y' or 'n'
	while [[ $choice != 'y' && $choice != 'n' ]]
	do 
		echo "Invalid choice !"		
		read -p "Do you want to enter another number ? (y/n) : " choice
		
	done

	#checking if the user wants only one number
	if [[ $choice == 'n' ]]

	then
		#Appending the new contact data to the database
		echo "#$contact_name : $contact_number" >> $FILE
		echo "Contact added successfully..."	
	
	#checking if the user wants to add multiple numbers
	elif [[ $choice == 'y' ]]
	then
		while [[ $choice == 'y' ]]
		do
		read -p "Enter new contact number: " number
		numbers_array+=( $number )
		read -p "Do you want to enter another number ? (y/n) : " choice

			#checking if the user entered somethig other than 'y' or 'n'
			while [[ $choice != 'y' && $choice != 'n' ]]
			do 
				echo "Invalid choice !"		
				read -p "Do you want to enter another number ? (y/n) : " choice
			done		
		done
		#appending the name and the first number
		echo "#$contact_name : $contact_number" >> $FILE	
		
		#appending the other phone numbers to that contact
		for i in "${numbers_array[@]}"
		do 
			sed -i "$ s/$/  $i/" $FILE 
		done
		echo "Contact added successfully..."
	else
		echo "Invalid choice!"	
	
	fi			
		
			 
exit

}

#function which views all the contacts saved in the database
function view
{

	#checking if the database is empty or not 
	if !( grep -qiP "#[\w+\s]*:" $FILE )
	then
		echo "Phonebook is empty!"
	else
	
		echo "Existing contacts"
		echo "-----------------"
		#displaying the existing contacts without the (#)
		grep -P "#[\w+\s]*:" $FILE | cut -c 2-
	fi		

exit	
}

#function which searchs the database by contact name
function search
{

	#checking if the database is empty or not
	if !( grep -qiP "#[\w+\s]*:" $FILE )
	then
		echo "Phonebook is empty!"
	else
	
		echo 
		echo "Searching contacts"
		echo "-----------------"
		#Getting the name of the contact to search for		
		read -p "Enter the name of the desired contact: " contact_name
		
		#checking for empty input	
		while [[ $contact_name = '' ]] 
		do
		   printf '%s\n' "No contact name entered"
		   read -p "Enter the name of the desired contact: " contact_name
		done
		
		#checking if the name entered does not exist in the database
		if ! (grep -qiP "\b$contact_name\b" $FILE); 
		then
		    echo "No contacts found!"
		else
			#displaying the matching contact(s)
			echo	
			echo "Contact(s) which match the entered name"
			echo "---------------------------------------"
			grep -iP "\b$contact_name\b" $FILE | cut -c 2-
		fi	
   
	fi

exit
}

#function which deletes all the data entries in the data base
function deleteAll
{

	
	
	#checking if the database is empty 
	if !( grep -qiP "#[\w+\s]*:" $FILE )
	then
		echo "Phonebook is already empty!"
	else
		#getting the line numbers of the existing contacts in the database	
		line_number=$(grep -nP "^#[\w\s]*.\s\d+" $FILE | cut -f1 -d:)
		#casting the variable as an array		
		line_number=( $line_number )
		
		#Getting the number of the line of first and last contact
		start=${line_number[0]}
		end=${line_number[-1]}
	
		#deleting all the contacts using the start and end
		sed -i "$start,$end"'d' $FILE
		
		#i tried using the same regex using with grep but it didn't work with sed
		echo "All contacts deleted successfully..."
	fi		
	
exit
}

#function which searches by contact name and deletes that contact
function deleteContact
{
#checking if the database is empty or not
	if !( grep -qiP "#[\w+\s]*:" $FILE )
	then
		echo "Phonebook is empty!"
	else
	
		echo "Delete contact"
		echo "--------------"
		#Getting the name of the contact which to be deleted
		read -p "Enter the name of the contact to be deleted: " contact_name

		while [[ $contact_name = '' ]] 
		do
		   printf '%s\n' "No contact name entered"
		  read -p "Enter the name of the contact to be deleted: " contact_name
		done

		#finding the line numbers of the found contacts
		line_number=$(grep -ni "$contact_name" $FILE | cut -f1 -d:)
		
		line_number=( $line_number )	

		#checking if the number of lines is greater than or equal i.e more than one match
		if [ ${#line_number[@]} -ge 2 ] 
		then 
			echo
			echo "Contacts found: "
			echo "----------------"
			#displaying the found contacts with their line numbers
			grep -niP "\b$contact_name\b" $FILE		
			echo
			#asking the user which line to delete 		
			read -p "Enter the number of the contact to be deleted: " line
			sed -i "$line"'d' $FILE		
			echo "Contact deleted successfully..."
		
		#checking if there is only one match		
		elif [ ${#line_number[@]} -eq 1 ]
		then
			echo -n "Contact found: "
			grep -i "$contact_name" $FILE | cut -c 2-	
			sed -i "$line_number"'d' $FILE		
			echo "Contact deleted successfully..."
		else
			echo "No contacts found matching that name.."
		fi	
	fi	

exit
}


#checking if there are no input parameters
if (( $# == 0 )) 

then 
	#Displaying the available options to the user
	echo
	echo "The available options for the phonebook are:
	- Insert new contact name and number, with the option "-i"
	- View all saved contacts details, with the option "-v"
	- Search by contact name, with the option "-s" 
	- Delete all records, with "-e"
	- Delete only one contact name, with "-d" "

#Checking if only one parameter is entered
elif (( $# == 1 )) 

then
	#checking which input parameter is inserted
	#and calling the related function
	case $1 in

	-i)		
		insert;;
		
	-v)
		view;;
		
	-s)
		search;;
		
	-e)
		deleteAll;;
		
	-d)
		deleteContact;;
		
	*)
		echo "Invalid option";;
	esac

else
	#checking if there are more than one input parameter
	echo "Please enter only one parameter -i,-v,-s,-e,-d"	
	
fi

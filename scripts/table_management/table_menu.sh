#! /usr/bin/bash

source "./scripts/table_management/table_management.sh"

table_menu(){
echo "Connected To Database: $DB_NAME"
    while true; 
    do
        echo -e "\nTable Operations Menu:"
        echo "1) Create Table"
        echo "2) List Tables"
        echo "3) Drop Table"
        echo "4) Rename Table"
        echo "5) Insert Into Table"
        echo "6) Select from Table"
        echo "7) Delete from Table"
        echo "8) Update Table"
        echo "9) Disconnect from Database"
        echo "10) Return back to the Main Menu"

        # Read user input with validation
        while true; do
            read -p "Select an Option (1-9): " option
            # Validate if input is a number between 1 and 10
            if validate_number "$option" 1 10; then
                break
            else
                echo "Please enter a valid number between 1 and 10"
            fi
        done
                        
        case $option in
            1) create_table ;;
            2) list_tables ;;
            3) drop_table ;;
            4) rename_table ;;
            5) insert_into_table ;;
            6) select_from_table ;;
            7) delete_from_table ;;
            8) update_table ;;
            9) 
                echo "Disconnected from Database: $DB_NAME"
                break 
                ;;
            10) main_menu ;;    
            *) echo "Invalid Option, Please Try Again." ;;
        esac
    done

}
# table_menu
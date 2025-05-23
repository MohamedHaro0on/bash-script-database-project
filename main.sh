#! /usr/bin/bash

source "./configs/config.sh"
source "./utils/utils.sh"
source "./scripts/table_management/table_menu.sh"
source "./scripts/db_management/db_management.sh"


PS3="Please, Select An Option: "

main_menu (){
      while true
        do
            select option in "Create Database" "List Databases" "Drop Database" "Connect Database" "Rename Database" "Exit"
        do
            case $option in
                "Create Database")
                    echo "You Chose To Create A Database:"
                    create_database
                    break  # Break the select loop, but not the while loop
                    ;;
                "List Databases")
                    echo "You Chose To List All Databases:"
                    list_databases
                    break
                    ;;
                "Drop Database")
                    echo "You Chose To Drop A Database:"
                    drop_database
                    break
                    ;;
            "Rename Database")
                    echo "You Chose To Rename A Database:"
                    rename_database
                    break
                    ;;
                "Connect Database")
                    echo "You Chose To Connect To A Database:"
                    connect_database
                    break
                    ;;
                "Exit")
                    echo "Exiting..."
                    exit 0  # Exit the entire script
                    ;;
                *)
                    echo "Invalid Option. Please Try Again."
                    break
                    ;;
            esac
        done
    done
}

main_menu 
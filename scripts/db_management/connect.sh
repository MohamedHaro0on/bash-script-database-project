#!/usr/bin/bash

connect_database() {
    echo -e "\nConnect to Database"
    echo "============================================== "
    
    # List available databases
    if ! list_all_databases; then
        return 1
    fi
    
    # Get database selection
    IFS= read -r -p $'\nEnter database number to connect (or 0 to cancel): ' choice
    
    # Check if user wants to cancel
    if validate_number "$choice" 0 0; then
        echo "Operation cancelled"
        return 0
    fi
    
    # Get database count
    local db_count=$(ls -l "$DBS_PATH" | grep "^d" | wc -l)
    
    # Validate choice
    if ! validate_number "$choice" 1 "$db_count"; then
        return 1
    fi
    
    # Get database name from choice
    local db_name=$(ls -l "$DBS_PATH" | grep "^d" | awk '{print $9}' | sed -n "${choice}p")
    
    # Set global variable and connect
    echo "this is the DBS_PATH : " $DBS_PATH  
    export ACTIVE_DB_PATH="$DBS_PATH/$db_name"
    export DB_NAME=$db_name
    echo "Connected to database: $ACTIVE_DB_PATH"
    table_menu
}
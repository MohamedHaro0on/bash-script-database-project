#!/usr/bin/bash

create_database() {
    echo -e "\nCreate Database"
    echo "============================================== "
    
    IFS= read -r -p "Enter Database Name: " db_name
    
    # Validate database name
    check_db_name "$db_name" || return 1
    
    # Check if database already exists
    if [[ -d "$DBS_PATH/$db_name" ]]; then
        echo "Error: Database '$db_name' already exists."
        return 1
    fi
    
    # Create database directory
    if mkdir "$DBS_PATH/$db_name" 2>/dev/null; then
        echo "Database '$db_name' created successfully."
        
        # Ask if user wants to connect to the new database
        if confirm_action "Would you like to connect to the new database?"; then
            export ACTIVE_DB_PATH="$DBS_PATH/$db_name"
            export DB_NAME="$db_name"
			echo "Connected to database: $DB_NAME"
            table_menu
        fi
    else
        echo "Error: Failed to create database '$db_name'"
        return 1
    fi
}
#!/usr/bin/bash
drop_database() {
    echo -e "\nDrop Database"
    echo "============="
    
    # List available databases
    if ! list_all_databases; then
        return 1
    fi

    # Get database count
    db_count=${#db_names[@]}

    while true
    do
        # Get database selection
        IFS= read -r -p $'\nEnter database number to connect (or 0 to cancel): ' choice
    
        # Validate choice
        if  validate_number "$choice" 1 "$db_count"; 
        then
            db_name="${db_names[$((choice - 1))]}"            
            break
        # Check if user wants to cancel
        elif validate_number "$choice" 0 0 && [[ "$choice" -eq 0 ]]
        then
            echo "Operation cancelled"
            return 0
        else
            echo "Invalid choice. Please select a number between 1 and $db_count, or 0 to cancel."
        fi
    done
    # Get database name from choice
    #local db_name=$(ls -l "$DBS_PATH" | grep "^d" | awk '{print $9}' | sed -n "${choice}p")
    
    # Confirm deletion
    if ! confirm_action "Are you sure you want to drop database '$db_name'?"; then
        return 1
    fi
    
    # Remove database
    if rm -r "$DBS_PATH/$db_name" 2>/dev/null; then
        echo "Database '$db_name' dropped successfully"
        
        # Clear global variable if it was the current database
        if [[ "$DB_NAME" == "$DBS_PATH/$db_name" ]]; then
            export DB_NAME=""
        fi
    else
        echo "Error: Failed to drop database '$db_name'"
        return 1
    fi
}
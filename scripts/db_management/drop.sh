#!/usr/bin/bash
drop_database() {
    echo -e "\nDrop Database"
    echo "============="
    
    # List available databases
    if ! list_all_databases; then
        return 1
    fi
    
    # Get database selection
    read -p $'\nEnter database number to drop (or 0 to cancel): ' choice
    
    # Check if user wants to cancel
    if [ "$choice" -eq 0 ]; then
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
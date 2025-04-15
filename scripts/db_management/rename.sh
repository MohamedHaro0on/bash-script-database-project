#!/usr/bin/bash
rename_database() {
    echo -e "\nRename Database"
    echo "============================================== "
    
    # List available databases
    if ! list_all_databases; then
        return 1
    fi
    
    # Get database selection
    IFS= read -r -p $'\nEnter database number to rename (or 0 to cancel): ' choice
    
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
    
    # Get old database name from choice
    local old_name=$(ls -l "$DBS_PATH" | grep "^d" | awk '{print $9}' | sed -n "${choice}p")
    
    # Get new name
    while true; do
       IFS= read -r -p"Enter new database name: " new_name

        # Validate new database name
        echo "this is the new db name : " $new_name 
        check_db_name "$new_name" || return 1

        
        # Check if new name already exists
        if [[ -d "$DBS_PATH/$new_name" ]]; then
            echo "Error: Database '$new_name' already exists"
            continue
        fi
        
        break
    done

    # Rename database
    if mv "$DBS_PATH/$old_name" "$DBS_PATH/$new_name" 2>/dev/null; then
        echo "Database renamed successfully"
        echo "'$old_name' → '$new_name'"
        
        # Update global variables if it was the current database
        if [[ "$DB_NAME" == "$old_name" ]]; then
            export DB_NAME="$new_name"
            export ACTIVE_DB_PATH="$DBS_PATH/$new_name"
        fi
    else
        echo "Error: Failed to rename database"
        return 1
    fi
}
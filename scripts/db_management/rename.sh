#!/usr/bin/bash
rename_database() {
    echo -e "\nRename Database"
    echo "============================================== "
    
    # List available databases
    if ! list_all_databases; then
        return 1
    fi
    db_count=${#db_names[@]}

    # Get user choice
    while true
    do
        IFS= read -r -p $'\nEnter database number to rename (or 0 to cancel): ' choice

        if validate_number "$choice" 1 "$db_count"; 
        then
            selected_database="${db_names[$((choice - 1))]}"
            break
        elif validate_number "$choice" 0 0 && [[ "$choice" -eq 0 ]]; 
        then
            echo "Operation cancelled"
            return 0
        else
            echo "Invalid choice. Please select a number between 1 and $db_count, or 0 to cancel."
        fi
    done

    # Get old database name from choice
    local old_name="$selected_database"
    
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
#!/usr/bin/bash
#======================================================================= Rename Table ===========================================================
rename_table() {
    echo -e "\nRename Table"
    echo "============================================== "
    
    # Check database and display tables
    check_db_exists || return 1
    display_tables || return 1
    
    # Get table selection
    while true; do
        IFS= read -r -p $'\nEnter table number to rename (or 0 to cancel): ' choice

        if validate_number "$choice" 1 ${#table_names[@]}; then
            selected_table=${table_names[$choice]}
            break
        elif validate_number "$choice" 0 0 && [[ "$choice" -eq 0 ]]; then            
            echo "Operation cancelled"
            return 0
        else
            echo "Not Matched Choice"
        fi
    done
    
    # Get new name
    while true; do
        IFS= read -r -p "Enter new table name: " new_table_name
        if ! validate_table_name "$new_table_name"; then
            continue
        fi
        if check_table_exists "$new_table_name"; then
            echo "Error: Table '$new_table_name' already exists"
            continue
        fi
        break
    done
    
    # Confirm and execute
    if confirm_action "Rename table '$selected_table' to '$new_table_name'?"; then
        if mv "$ACTIVE_DB_PATH/$selected_table" "$ACTIVE_DB_PATH/$new_table_name" 2>/dev/null; then
            echo "Table renamed successfully"
            echo "'$selected_table' → '$new_table_name'"
        else
            echo "Error renaming table"
            return 1
        fi
    fi
}
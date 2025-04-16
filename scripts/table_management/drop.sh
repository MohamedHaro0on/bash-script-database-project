#!/usr/bin/bash
#======================================================================= Drop Table ===========================================================
drop_table() {
    echo -e "\nDrop Table"
    echo "============================================== "
    
    # Check database and display tables
    check_db_exists || return 1
    display_tables || return 1
    
    # Get table selection
    while true; do
        IFS= read -r -p $'\nEnter table number to drop (or 0 to cancel): ' choice

            if validate_number "$choice" 1 ${#table_names[@]}; 
            then
                selected_table=${table_names[$choice]}
                break
            elif validate_number "$choice" 0 ${#table_names[@]} && [[ "$choice" -eq 0 ]]; 
            then
                echo "Operation cancelled"
                return 0
            else
                echo "Invalid choice. Please select a number between 1 and ${#table_names[@]}, or 0 to cancel."
            fi
    done
    
    # Confirm and execute
    if confirm_action "Are you sure you want to drop table '$selected_table'?"; then
        if rm -r "$ACTIVE_DB_PATH/$selected_table" 2>/dev/null; then
            echo "Table '$selected_table' dropped successfully"
        else
            echo "Error dropping table '$selected_table'"
            return 1
        fi
    fi
}
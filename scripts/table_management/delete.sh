#! /usr/bin/bash


#========================================================================== Delete Functionality ========================================================

delete_from_table () {
    while true; do
        # Check database and display tables
        check_db_exists || return 1
        display_tables || return 1

        # Get table selection
        while true; do
            IFS= read -r -p $'\nSelect table number to delete from (or 0 to cancel): ' choice

            if validate_number "$choice" 0 ${#table_names[@]}; then
                if [ "$choice" -eq 0 ]; then
                    echo "Operation cancelled"
                    return 0
                fi
                selected_table=${table_names[$choice]}
                break
            fi
        done

        # Populate global cols array
        list_columns "$selected_table"

        # Get column selection
        while true; do
            IFS= read -r -p $'\nSelect column number: ' col_choice

            if validate_number "$col_choice" 1 ${#cols[@]}; then
                col_choice=$((col_choice - 1))
                selected_column=${cols[$col_choice]}
                break
            fi
            if validate_number "$choice" 0 0 ; then
                echo "Operation cancelled"
                return 0
            fi
        done

        # Prompt for a value to match in the selected column
        IFS= read -r -p "Enter the value to find records where $selected_column equals: " value_to_delete

        # Read and display matched records
        data_file="$ACTIVE_DB_PATH/$selected_table/data"
        matched_records=()
        record_index=1  # Start index at 1

        while IFS= read -r line; do
            IFS=':' read -ra fields <<< "$line"
            if [[ "${fields[$col_choice]}" == "$value_to_delete" ]]; then
                echo "$record_index: $line"
                matched_records+=("$line")
                ((record_index++))
            fi
        done < "$data_file"

        if [ ${#matched_records[@]} -eq 0 ]; then
            echo "============================"
            echo "No matching records found."
            echo "============================"
            continue
        fi

        # Allow user to select which record to delete
        while true; do
            IFS= read -r -p "Select record number to delete (or 0 to cancel): " record_choice

            if validate_number "$record_choice" 0 ${#matched_records[@]}; then
                if [ "$choice" -eq 0 ]; then
                    echo "Operation cancelled"
                    return 0
                fi
                break
            fi
        done

        # Rewrite the data file excluding the selected matching record
        temp_file=$(mktemp)

        while IFS= read -r line; do
            IFS=':' read -ra fields <<< "$line"
            if [[ "${fields[$col_choice]}" != "$value_to_delete" ]]; then
                echo "$line" >> "$temp_file"
            fi
        done < "$data_file"

        for i in "${!matched_records[@]}"; do
            if [[ $((i + 1)) -ne $record_choice ]]; then
                echo "${matched_records[$i]}" >> "$temp_file"
            fi
        done

        mv "$temp_file" "$data_file"
        echo "============================"
        echo "Record deleted successfully!"
        echo "============================"

        # Ask if the user wants to perform another deletion
        IFS= read -r -p "Do you want to delete another record? (y/n): " continue_choice
        if [[ "$continue_choice" != "y" ]]; then
            break
        fi
    done
}
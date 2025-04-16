#!/usr/bin/bash
#======================================================================= Insert Into Table ===========================================================
insert_into_table() {

    echo -e "\nInsert Into Table"
    echo "============================================== "
    
    # Check database and display tables
    check_db_exists || return 1
    display_tables || return 1
   
    # Get table selection
    while true; do
        IFS= read -r -p $'\nSelect table number to insert into (or 0 to cancel): ' choice
        
        if validate_number "$choice" 0 ${#table_names[@]}; then
            selected_table=${table_names[$choice]}
            break
        fi
        if validate_number "$choice" 0 0; then
            echo "Operation cancelled"
            return 0
        fi
    done
    
    # Read metadata
    metadata_file="$ACTIVE_DB_PATH/$selected_table/metadata"
    if [ ! -f "$metadata_file" ]; then
        echo "Metadata file not found for $selected_table"
        return 1
    fi
    IFS=',' read -ra COLUMNS <<< "$(cat "$metadata_file")"
        # Identify primary key column index
    pk_index=-1
    for i in "${!COLUMNS[@]}"; do
        IFS=':' read -ra COL_INFO <<< "${COLUMNS[i]}"
        if [[ "${COL_INFO[2]}" == "PK" ]]; then
            pk_index=$i
            pk_name=${COL_INFO[0]}
            break
        fi
    done

    if [[ $pk_index -eq -1 ]]; then
        echo "Error: No primary key defined in the table metadata!"
        return 1
    fi

    # Extract existing primary key values
    data_file="$ACTIVE_DB_PATH/$selected_table/data"
    declare -A existing_pks

    if [[ -f "$data_file" ]]; then
        while IFS=":" read -ra row; 
        do
		if [[ ${#row[@]} -gt $pk_index ]]; 
		then
            		existing_pks["${row[$pk_index]}"]=1
        	fi
        done < "$data_file"
    fi

    # Get values
    data_string=""
    echo -e "\nEnter values for each column:"
    for column in "${COLUMNS[@]}"; do
        IFS=':' read -ra COL_INFO <<< "$column"
        col_name=${COL_INFO[0]}
        col_type=${COL_INFO[1]}
        is_pk=${COL_INFO[2]}
        while true; do
            IFS= read -r -p "$col_name ($col_type): " value
            if validate_data_type "$value" "$col_type"; 
            then
            if [[ "$col_name" == "$pk_name" ]]; then  # Check if this is the PK column
                    if [[ -n "${existing_pks[$value]}" ]]; then
                        echo "Error: Primary key '$value' already exists! Please enter a unique value."
                        continue
                    fi
                fi
                break
            fi
            echo "Invalid input. Please enter a valid $col_type."
        done
        # Build the record string
        if [ -z "$data_string" ]; then
            data_string="$value"
        else
            data_string="$data_string:$value"
        fi
    done
    
    # Save record
    data_file="$ACTIVE_DB_PATH/$selected_table/data"
    if echo "$data_string" >> "$data_file"; then
        echo -e "\nRecord inserted successfully!"
    else
        echo -e "\nError inserting record!"
        return 1
    fi
}
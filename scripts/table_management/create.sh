
#!/usr/bin/bash

#======================================================================= Create Table ===========================================================
create_table() {
    echo -e "\nCreate Table"
    echo "============================================== "
    echo $DB_NAME 
    # Check database existence
    check_db_exists || return  # returns 1 if database does not exist
    
    # Get and validate table name
    while true; do
        IFS= read -r -p "Enter table name: " table_name
        if ! validate_table_name "$table_name"; then
            continue
        fi
        if check_table_exists "$table_name"; then
            echo "Error: Table already exists!"
            continue
        fi
        break
    done
    
    # Create table structure
    if ! mkdir "$ACTIVE_DB_PATH/$table_name" 2>/dev/null; then
        echo "Error: Failed to create table directory"
        return 1
    fi
    touch "$ACTIVE_DB_PATH/$table_name/metadata"
    touch "$ACTIVE_DB_PATH/$table_name/data"
    
    # Get column count
    while true; do
        IFS= read -r -p "Enter number of columns: " col_count
        if validate_number "$col_count" 1 100; then
            break
        fi
    done
    
    # Get column details
    metadata=""
    # Primary Key Check
    pk=0
    for ((i=1; i<=$col_count; i++)); 
    do
        # Get and validate column name
        while true; do
            IFS= read -r -p "Enter name for column $i: " col_name
            if validate_column_name "$col_name"; then
                break
            fi
        done
        
        # Display data types
        echo -e "\nAvailable data types:"
        for ((j=0; j<${#SUPPORTED_DATATYPES[@]}; j++)); do
            echo "$((j+1))) ${SUPPORTED_DATATYPES[j]}"
        done
        
        # Get data type
        while true; do
            IFS= read -r -p "Select data type for $col_name (1-${#SUPPORTED_DATATYPES[@]}): " type_choice
            if validate_number "$type_choice" 1 ${#SUPPORTED_DATATYPES[@]}; then
                selected_type=${SUPPORTED_DATATYPES[$((type_choice-1))]}
                break
            fi
        done
       # Check if this column should be the primary key
        if [ $pk -eq 0 ]
        then
        	IFS= read -r -p "Do you Want to make $col_name Primary Key (y/n): " checkPk
        	if [[ $checkPk = "y" ]]
        	then
        		metadata+="$col_name:$selected_type:PK"
        		pk=1
        	else
        		metadata+="$col_name:$selected_type"
        	fi
        else
            metadata+="$col_name:$selected_type"
        fi    
        
        if [ $i -ne $col_count ]
        then
        	metadata+=","
        fi
    done
    
    # Ensure at least one PK is set
    if [ $pk -eq 0 ]; then
    	echo "Error: At least one column must be set as a Primary Key."
    	return 1
    fi
    
    # Save metadata
    echo "$metadata" > "$ACTIVE_DB_PATH/$table_name/metadata"
    echo "Table '$table_name' created successfully!"
}
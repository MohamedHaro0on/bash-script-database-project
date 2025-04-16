#! /usr/bin/bash

#========================================================================== Select Functionality ========================================================
select_from_table(){
echo -e "\nSelect From Table"
echo "============================================== "
#1] Display Available Tables
# Ensure An Active DataBase is selected 
if [[ -z "$ACTIVE_DB_PATH" ]]
then
	echo "No Database Selected! Please Connect To a Database First."
	return 1
fi

# Get List Of Tables
local tables=($(ls "$ACTIVE_DB_PATH")) # Store tables in an array

if [[ ${#tables[@]} -eq 0 ]]
then
	echo "No Tables Found in Database $ACTIVE_DB_PATH"
	return 1
fi

# Display Tables
echo -e "\n Available Tables: "
local index=1
for table in "${tables[@]}"
do
	echo "$index) $table"
	((index++))
done

#2] Allow the User to Choose a Table
# Get User Selection
while true
do
	IFS= read -r -p $'\n Select Table Number To Select(or 0 To Cancel) : ' choice
	if validate_number "$choice" 0 0; 
	then
		echo "Operation Cancelled"
		return 0
	fi
	if [[ $choice -ge 1 && $choice -le ${#tables[@]} ]]
	then
		selected_table="${tables[$((choice-1))]}"
		break
	else
		echo "Inavlid Selection. Please,Enter a Number Between 1 & ${#tables[@]}"
	fi
done

#3] Read the Table's Structure (Column Names)
#Read Metadata file & data file
metadata_file="$ACTIVE_DB_PATH/$selected_table/metadata"
data_file="$ACTIVE_DB_PATH/$selected_table/data"

if [[ ! -f "$metadata_file" || ! -f "$data_file" ]]; 
then
        echo "Error: Table $selected_table Does Not Exist!"
        return 1
fi

#Read metadata (Extract Column Names)
IFS=',' read -ra COLUMNS < "$metadata_file"
#3-Prompt the user for the column to search by and the value.
# Display Columns
echo -e "\n Available Columns: "
local index=1
for column in "${COLUMNS[@]}"
do
	echo "$index) $column"
	((index++))
done

#4] Ask for Columns to Display (Projection)
   # Get User Selection
	IFS= read -r -p $'\nSelect Column Numbers To Display (comma-separated, or 0 for all): ' choice
	selected_indexes=()
	if validate_number "$choice" 0 0;
	then
        	# Select all columns
        	for ((i = 0; i < ${#COLUMNS[@]}; i++)) 
        	do
            		selected_indexes+=("$i")
        	done
        else
		IFS=',' read -ra column_indexes <<< "$choice"
    		for col_index in "${column_indexes[@]}"
    		do
            		if [[ $col_index -ge 1 && $col_index -le ${#COLUMNS[@]} ]] 
            		then
                		selected_indexes+=("$((col_index - 1))")
            		else
                		echo "Invalid selection: $col_index"
                		return 1
            		fi
        	done
   	fi
#5] Ask for Filtering Conditions (Selection)
    IFS= read -r -p $'\nDo You Want To Apply A Filter Condition? (y/n): ' apply_filter
    if [[ "$apply_filter" =~ ^[Yy](es)?$ ]]
    then
    	IFS= read -r -p "Enter Column Number For Filtering: " filter_col_index
    	if [[ $filter_col_index -ge 1 && $filter_col_index -le ${#COLUMNS[@]} ]] 
    	then
            filter_col_index=$((filter_col_index - 1))  # Convert to zero-based index
            IFS= read -r -p "Enter Value To Match in ${COLUMNS[$filter_col_index]}: " filter_value
    	else
    		echo "Invalid Column Selection For Filtering."
    		apply_filter="n"
    	fi
    else
    	apply_filter="n"
    fi
#6] Read and Process the Table Data & Display the Results
echo -e "\nSelected Records: "

# Read and process the table data
while IFS=: read -r -a row 
do
	if [[ "$apply_filter" =~ ^[Yy](es)?$ ]] 
        then
        	if [[ "${row[$filter_col_index]}" != "$filter_value" ]]; 
            	then
                	continue  # Skip this row if it doesn't match the filter
            	fi
        fi

        # Print selected columns
        for index in "${selected_indexes[@]}" 
        do
            echo -n "${row[index]} "
        done
        echo  # Move to the next line
    done < "$data_file"
}
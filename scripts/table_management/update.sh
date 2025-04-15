#!/usr/bin/bash

#======================================================================= UPDATE Functionality ==================================================================
update_table(){
echo -e "\nUpdate Table"
echo "============================================== "
    
#1-Ensure An Active DataBase is selected 
if [[ -z "$ACTIVE_DB_PATH" ]]
then
	echo "No Database Selected! Please Connect To a Database First."
	return 1
fi

#2-Get List Of Tables
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

# Get User Selection
while true
do
	IFS= read -r -p $'\n Select Table Number To Update(or 0 To Cancel) : ' choice
	if [[ $choice -eq 0 ]] 
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
#3-Read Metadata file & data file
metadata_file="$ACTIVE_DB_PATH/$selected_table/metadata"
data_file="$ACTIVE_DB_PATH/$selected_table/data"

if [[ ! -f "$metadata_file" || ! -f "$data_file" ]]; 
then
        echo "Error: Table $selected_table Does Not Exist!"
        return 1
fi

#Read metadata (Extract Column Names)
IFS=',' read -ra COLUMNS < "$metadata_file"
  
#4-Prompt the user for the column to search by and the value.
# Display Columns
echo -e "\n Available Columns: "
local index=1
for column in "${COLUMNS[@]}"
do
	echo "$index) $column"
	((index++))
done

# Get User Selection
while true
do
	IFS= read -r -p $'\n Select Column Number To Update(or 0 To Cancel) : ' choice
	if [[ $choice -eq 0 ]] 
	then
		echo "Operation Cancelled"
		return 0
	fi
	if [[ $choice -ge 1 && $choice -le ${#COLUMNS[@]} ]]
	then
        	IFS=":" read -r search_column _ <<< "${COLUMNS[$((choice-1))]}"
		column_index=$((choice-1))
		break
	else
		echo "Inavlid Selection. Please,Enter a Number Between 1 & ${#COLUMNS[@]}"
	fi
done

IFS= read -r -p "Enter value to search for: " search_value

# 5. Search for Matching Records
    matches=()
    while IFS= read -r line 
    do
        IFS=":" read -ra values <<< "$line"
        if [[ "${values[column_index]}" == "$search_value" ]] 
        then
            matches+=("$line")
        fi
    done < "$data_file"

    if [[ ${#matches[@]} -eq 0 ]]; then
        echo "Error: No Matching Records Found!"
        return 1
    fi

# 6. Handle Multiple Matches
    if [[ ${#matches[@]} -gt 1 ]] 
    then
        echo -e "\nMultiple Matches Found:"
        for i in "${!matches[@]}" 
        do
            echo "$((i + 1))) ${matches[$i]}"
        done

        while true 
        do
            IFS= read -r -p $'\n Select the record to update (or 0 to Cancel): ' record_choice
            if [[ $record_choice -eq 0 ]] 
            then
                echo "Update Cancelled."
                return 0
            fi
            if [[ $record_choice -ge 1 && $record_choice -le ${#matches[@]} ]] 
            then
                old_record="${matches[$((record_choice - 1))]}"
                break
            else
                echo "Invalid choice. Please select a valid record number."
            fi
        done
    else
        old_record="${matches[0]}"
    fi
# 7. Display and Update Selected Record
echo -e "\nSelected Record: $old_record"
IFS=":" read -ra values <<< "$old_record"

IFS=":" read -r col_name col_type <<< "${COLUMNS[column_index]}"
IFS= read -r -p "Enter new value for $col_name ($col_type) (leave empty to keep current): " new_value

if [[ -z "$new_value" ]] 
then
    echo "No changes were made."
    return 0
fi

# Validate the new value
if  ! validate_data_type "$new_value" "$col_type" 
then
    echo "Invalid input for $col_name. Please enter a valid $col_type."
    return 1
fi

# Update only the selected column
values[column_index]="$new_value"

# Reconstruct the updated record
new_record=$(IFS=":"; echo "${values[*]}")

# Replace the old record with the new one in the file
sed -i "s|$old_record|$new_record|" "$data_file"

echo -e "\nRecord Updated Successfully!"
}

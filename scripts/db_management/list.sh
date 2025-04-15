#! /usr/bin/bash


list_databases() {
    echo -e "\nList Databases"
    echo "============================================== "
    
    if ! list_all_databases; then
        echo "No databases found in $DBS_PATH"
        return 1
    fi
    
    # Display total count
    local count=$(ls -l "$DBS_PATH" | grep "^d" | wc -l)
    echo -e "\nTotal databases: $count"
}




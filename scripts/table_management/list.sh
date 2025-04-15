#!/usr/bin/bash
#======================================================================= List Table ======================================================================
list_tables() {
    echo -e "\nList Tables"
    echo "============================================== "
    
    # Check database existence
    check_db_exists || return 1
    
    # Display tables
    local table_count=0
    echo "CHECK:$ACTIVE_DB_PATH"
    pwd

    for table in "$ACTIVE_DB_PATH"/* ; do
        if [ -d "$table" ] && [ -f "$table/metadata" ]; then
            ((table_count++))
            table_name=$(basename "$table")
            
            if [ -f "$table/metadata" ]; then
                metadata=$(cat "$table/metadata")
                records_count=$(wc -l < "$table/data" 2>/dev/null || echo 0)
                
                echo -e "\nTable: $table_name"
                echo "Records: $records_count"
                echo "Columns:"
                
                IFS=',' read -ra COLUMNS <<< "$metadata"
                for column in "${COLUMNS[@]}"; do
                    IFS=':' read -ra COL_INFO <<< "$column"
                    printf "  %-20s %-10s\n" "${COL_INFO[0]}" "${COL_INFO[1]}"
                done
                echo "------------------------"
            else
                echo "Table '$table_name' (metadata not found)"
            fi
        fi
    done
    
    if [ $table_count -eq 0 ]; then
        echo "No tables found"
        return 1
    fi
    
    echo -e "\nTotal tables: $table_count"
}
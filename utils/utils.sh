#!/usr/bin/bash

# Database Operations Utils
check_db_name() {
    local name=$1
    if [[ -z "$name" ]]; then
        echo "Database name cannot be empty."
        return 1
    fi
    # Check for backslash 
    if [[ "$db_name" == *\\* ]]; then
        echo "Error: Database name cannot contain backslashes"
        return 1
    fi
    if [[ ! "$name" =~ ${REGEX_PATTERNS["DB_NAME_REGEX"]} ]]; then
        echo "Invalid database name. Must start with a letter and contain only letters, numbers, and underscores."
        return 1
    fi
    return 0
}

ensure_ACTIVE_DB_PATH() {
    mkdir -p "$DBS_PATH"
}

list_all_databases() {
    if [[ ! -d "$DBS_PATH" ]]; then
        echo "Databases directory does not exist."
        return 1
    fi

    db_names=()
    for dir in "$DBS_PATH"/*; do
        if [[ -d "$dir" ]]; then
            db_names+=("$(basename "$dir")")
        fi
    done

    if [[ ${#db_names[@]} -eq 0 ]]; then
        echo "No databases found."
        return 1
    fi

    echo -e "\nAvailable Databases:"
    echo "==================="
    for i in "${!db_names[@]}"; do
        echo "$((i + 1))) ${db_names[$i]}"
    done

    return 0
}
# Database and Table existence checks
check_db_exists() {
    echo "Checking database: $DB_NAME" # Debugging
    echo "Checking database path: $DBS_PATH" # Debugging
    if [ ! -d "$DBS_PATH/" ]; then
        echo "Database '$DB_NAME' does not exist!"
        return 1
    fi
    return 0
}

check_table_exists() {
    TABLE_NAME=$1
    if [ ! -d "$ACTIVE_DB_PATH/$TABLE_NAME" ]; then
        # echo "Table '$TABLE_NAME' does not exist!"
        return 1
    fi
    return 0
}

# Table Operations Utils
get_tables() {
    table_names=()
    local number=1
    for table in "$ACTIVE_DB_PATH"/*/; do
        if [ -d "$table" ]; then
            local table_name=$(basename "$table")
            table_names[$number]=$table_name
            echo "$number) $table_name"
            ((number++))
        fi
    done
    echo "Total tables: $((number-1))"
    return $((number-1))
}
list_columns () {
    local table=$1
    local metadata="$ACTIVE_DB_PATH/$table/metadata"
    if [[ ! -f "$metadata" ]]; then
        echo "Error: Metadata file for table '$table' not found."
        return 1
    fi

    # Read and process the metadata line
    local line
    read -r line < "$metadata"
    echo "Metadata line: $line"  # Debugging output

    # Declare cols as a global array
    declare -g -a cols=()
    IFS=',' read -ra col_defs <<< "$line"
    for def in "${col_defs[@]}"; do
        cols+=("${def%%:*}")
    done

    # Debugging output
    echo "Columns found: ${#cols[@]}"
    printf "%s\n" "${cols[@]}"
    return 0
}

display_tables() {
    echo -e "\nAvailable tables:"
    echo "=============================================="
    get_tables
    table_count=$?
    echo -e "\n table names : ${table_names[@]}"
    if [ $table_count -eq 0 ]; then
        echo "No tables found in database '$DB_NAME'"
        return 1
    fi
    return 0
}

get_table_record_count() {
    local table_name=$1
    if [ -f "$ACTIVE_DB_PATH/$table_name/data" ]; then
        wc -l < "$ACTIVE_DB_PATH/$table_name/data" 2>/dev/null || echo 0
        return 0
    fi
    echo 0
    return 1
}

# Data type regex patterns
declare -A REGEX_PATTERNS
REGEX_PATTERNS[string]="^[a-zA-Z0-9\.\ \-\_\,\']+$"
REGEX_PATTERNS[integer]='^[\-]?[0-9]+$'
REGEX_PATTERNS[float]='^[\-]?[0-9]+\.?[0-9]*$'
REGEX_PATTERNS[date]='^[0-9]{4}\-[0-9]{2}\-[0-9]{2}$'
REGEX_PATTERNS[DB_NAME_REGEX]='^[a-zA-Z][a-zA-Z0-9_]*$'
REGEX_PATTERNS[TABLE_NAME_REGEX]='^[a-zA-Z][a-zA-Z0-9_]*$'
REGEX_PATTERNS[COLUMN_NAME_REGEX]='^[a-zA-Z][a-zA-Z0-9_]*$'
# Supported data types array
SUPPORTED_DATATYPES=("string" "integer" "float" "date")

# Data type validation function
validate_data_type() {
    value=$1
    full_type=$2
    base_type=$(echo "$full_type" | cut -d':' -f1)  # Extract "integer" from "integer:PK"
    #echo "DEBUG: Checking value='$value' with extracted type='$base_type'"
    #echo "DEBUG: Using regex pattern '${REGEX_PATTERNS[integer]}'"

    case $base_type in
        "integer")
            if [[ "$value" =~ ${REGEX_PATTERNS["integer"]} ]]; then
                #echo "DEBUG: '$value' is a valid integer"
                return 0
            fi
            echo "Invalid input for $value! Expected type: $base_type."
            ;;
        "float")
            if [[ "$value" =~ ${REGEX_PATTERNS["float"]} ]]; then
                return 0
            fi
            echo "Invalid input for $value! Expected type: $base_type."
            ;;
        "string")
            if [[ "$value" =~ ${REGEX_PATTERNS["string"]} ]]; then
                return 0
            fi
            echo "Invalid input for $value! Expected type: $base_type."
            ;;
        "date")
            if [[ "$value" =~ ${REGEX_PATTERNS["date"]} ]]; then
                return 0
            fi
            echo "Invalid input for $value! Expected type: $base_type (YYYY-MM-DD)."
            ;;
        *)
            echo "Unknown data type: $full_type"
            ;;
    esac
    return 1
}
# Name validation functions
validate_table_name() {
    local name=$1
    if [[ -z "$name" ]]; then
        echo "Table name cannot be empty."
        return 1
    fi
    # Check for backslash 
    if [[ "$name" == *\\* ]]; then
        echo "Error: Table name cannot contain backslashes"
        return 1
    fi
    if [[ ! "$name" =~ ${REGEX_PATTERNS["TABLE_NAME_REGEX"]} ]]; then
        echo "Invalid table name. Must start with a letter and contain only letters, numbers, and underscores."
        return 1
    fi
    return 0
}

validate_column_name() {
    local name=$1
    if [[ -z "$name" ]]; then
        echo "Column name cannot be empty."
        return 1
    fi
    # Check for backslash 
    if [[ "$name" == *\\* ]]; then
        echo "Error: Column name cannot contain backslashes"
        return 1
    fi
    if [[ ! "$name" =~ ${REGEX_PATTERNS["COLUMN_NAME_REGEX"]} ]]; then
        echo "Invalid column name. Must start with a letter and contain only letters, numbers, and underscores."
        return 1
    fi
    return 0
}

# Input validation 
validate_number() {
    local num=$1
    local min=$2
    local max=$3
    if [[ ! "$num" =~ ^[0-9]+$ ]] || [ "$num" -lt "$min" ] || [ "$num" -gt "$max" ]; then
        #echo "Please enter a number between $min and $max"
        return 1
    fi
    return 0
}

# Confirmation 
confirm_action() {
    local message=$1
    read -p "$message (y/n): " confirm
    if [[ "$confirm" == [yY] ]]; then
        return 0
    fi
    echo "Operation cancelled."
    return 1
}





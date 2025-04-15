
#!/usr/bin/bash


# Ensure database directory exists
ensure_ACTIVE_DB_PATH

# Source files using absolute paths
source "./scripts/table_management/table_menu.sh"
source "./scripts/db_management/connect.sh"
source "./scripts/db_management/create.sh"
source "./scripts/db_management/drop.sh"
source "./scripts/db_management/list.sh"
source "./scripts/db_management/rename.sh"
#!/bin/bash

# Usage:
# Download dataset from https://automaticknowledge.org/food-for-thought/all-FHRS-GB-16-oct-2021-extract.csv
# chmod +x update_csv_path.sh
# ./update_csv_path.sh path/to/001_load_data.sql /path/to/csv_file.csv

SQL_FILE="$1"
CSV_PATH="$2"

if [[ -z "$SQL_FILE" || -z "$CSV_PATH" ]]; then
    echo "Usage: $0 <sql_file> <csv_file_path>"
    exit 1
fi

# Replace line 35 with the new CSV path
sed -i.bak "35s|.*|LOAD DATA LOCAL INFILE '$CSV_PATH'|" "$SQL_FILE"

echo "Line 35 updated in $SQL_FILE"
echo "Backup of original file saved as $SQL_FILE.bak"
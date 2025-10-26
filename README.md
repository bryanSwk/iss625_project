# ISS625 Project

## Load Data

```
- Download dataset from https://automaticknowledge.org/food-for-thought/all-FHRS-GB-16-oct-2021-extract.csv
- chmod +x update_csv_path.sh
- ./update_csv_path.sh path/to/001_load_data.sql /path/to/csv_file.csv
```

Allow `LOAD DATA LOCAL INFILE`

- Add OPT_LOCAL_INFILE=1 to MySQL Workbench -> Manage Server Connections -> Advanced -> Others:

Run SQL Queries in order:
1. 001_load_data.sql
2. 002_preprocess_data.sql

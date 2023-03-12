#!/bin/bash

DB_FILE="users.db"

check_db_file() {
    if [ ! -f "$DB_FILE" ]; then
        echo "The database file '$DB_FILE' does not exist. Do you want to create it? (y/n)"
        read confirm
        if [ "$confirm" != "y" ]; then
            exit 0
        fi
        touch "$DB_FILE"
    fi
}

validate_username() {
    username="$1"
    if [ -z "$username" ]; then
        echo "The username cannot be empty"
        return 1
    fi
    if [[ ! "$username" =~ ^[a-zA-Z]+$ ]]; then
        echo "The username can contain only latin letters"
        return 1
    fi
}

validate_role() {
    role="$1"
    if [ -z "$role" ]; then
        echo "The role cannot be empty"
        return 1
    fi
    if [[ ! "$role" =~ ^[a-zA-Z]+$ ]]; then
        echo "The role can contain only latin letters"
        return 1
    fi
}

add_record() {
    echo "Enter the username:"
    read username
    validate_username "$username" || return 1
    echo "Enter the role:"
    read role
    validate_role "$role" || return 1
    echo "$username, $role" >> "$DB_FILE"
    echo "Added new record: $username, $role"
}

backup_db() {
    timestamp=$(date +"%Y%m%d_%H%M%S")
    backup_file="$timestamp-users.db.backup"
    cp "$DB_FILE" "$backup_file"
    echo "Created backup file: $backup_file"
}

restore_db() {
    backup_files=($(ls -t -1 *-users.db.backup))
    last_backup=$(echo "$backup_files" | head -n 1)
    if [ -z "$last_backup" ]; then
        echo "No backup file found"
        return 1
    fi
    cp "$last_backup" "$DB_FILE"
    echo "Restored database from backup file: $last_backup"
}

find_record() {
    echo "Enter the username:"
    read username
    validate_username "$username"|| return 1
    
    if grep -q "^$username, " "$DB_FILE"; then
        grep "^$username, " "$DB_FILE" | nl
    else
        echo "User not found"
    fi
}

list_records() {
    if [ "$1" = "--inverse" ]; then
        awk -F ', ' '{print NR". "$0}' "$DB_FILE" | tac
    else
        awk -F ', ' '{print NR". "$0}' "$DB_FILE"
    fi
    
}

case "$1" in
    "add")
        check_db_file
        add_record
    ;;
    "backup")
        check_db_file
        backup_db
    ;;
    "restore")
        check_db_file
        restore_db
    ;;
    "find")
        check_db_file
        find_record
    ;;
    "list")
        check_db_file
        list_records "$2"
    ;;
    "help"|*)
        echo "Usage: $0 <command>"
        echo ""
        echo "Available commands:"
        echo "  add            Add a new record to the database"
        echo "  backup         Create a backup file of the database"
        echo "  restore        Restore the database from the last backup"
        echo "  find           Find a record by username"
        echo "  list [--inverse]   List all records in the database. With --inverse, list records in reverse order."
        echo "  help           Show this help message"
    ;;
esac
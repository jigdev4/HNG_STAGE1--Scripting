#!/bin/bash
#=================================================
# Name: Joseph Eniola David
# Date: 1/07/2024
#
# This script assumes the input file is a data file of employees
# and must be in the following format (and also
# assumes this is the first line of the file):
# Name:Group
#================================================

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

# Check if the user has provided the input file as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <user_file>"
    exit 1
fi

INPUT_FILE="$1"

# Log and password file locations
LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.txt"

# Create or clear log and password files
#sudo truncate -s 0 "$LOG_FILE"
#sudo truncate -s 0 "$PASSWORD_FILE"

# Function to set up log and password files
setup_files() {
    mkdir -p /var/secure
    chmod 700 /var/secure
    touch $PASSWORD_FILE
    chmod 600 $PASSWORD_FILE
    touch $LOG_FILE
}

# Function to log messages
log_message() {
    local message=$1
    echo "[$(date)] $message" >> $LOG_FILE
}

# Function to generate a random password using openssl
generate_password() {
    openssl rand -base64 12
}

# Function to create a user
create_user() {
    local username=$1
    local groups=$2

    # Trim whitespace
    username=$(echo "$username" | xargs)
    groups=$(echo "$groups" | xargs)

    # Validate username
    if [[ -z "$username" ]]; then
        log_message "Empty username. Skipping."
        return
    fi

    # Check if user already exists
    if id "$username" &>/dev/null; then
        log_message "User $username already exists. Skipping."
        return
    fi

    # Create the user and the user's personal group
    useradd -m "$username" &>> $LOG_FILE
    if [ $? -ne 0 ]; then
        log_message "Failed to create user $username."
        return
    fi

    # Set the user's primary group to match the username
    usermod -g "$username" "$username" &>> $LOG_FILE
    if [ $? -ne 0 ]; then
        log_message "Failed to set primary group for user $username."
        return
    fi

    # Create the additional groups if they don't exist and add the user to them
    IFS=',' read -ra ADDR <<< "$groups"
    for group in "${ADDR[@]}"; do
        group=$(echo "$group" | xargs) # Trim whitespace
        if ! getent group "$group" &>/dev/null; then
            groupadd "$group" &>> $LOG_FILE
            if [ $? -ne 0 ]; then
                log_message "Failed to create group $group."
                continue
            fi
        fi
        usermod -aG "$group" "$username" &>> $LOG_FILE
    done

    # Generate a random password for the user
    local password
    password=$(generate_password)
    echo "$username:$password" | chpasswd

    # Log the password securely
    echo "$username,$password" >> $PASSWORD_FILE
    log_message "User $username created with groups $groups."
}

# Setup log and password files
setup_files

# Log the start of the script
log_message "User creation script started."

# Read the user file line by line
while IFS=';' read -r username groups; do
    create_user "$username" "$groups"
done < "$INPUT_FILE"

# Log the end of the script
log_message "User creation script finished."

exit 0


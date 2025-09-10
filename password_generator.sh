#!/bin/bash

# File to hold the encrypted passwords
OUTPUT_FILE="passwords.txt"

# Greeting
echo "Welcome to password generator"

echo "Please enter number of passwords:"

# Read the input given by user and store in variable
read NUMBER_OF_PASSWARD

# Ask the user how long the password should be
echo "Please enter the length of the password:"

# Read the input given by user and store in variable
read PASS_LENGTH

# Validate input
while true; do
    if ! [[ $PASS_LENGTH =~ ^[0-9]+$ ]]; then
        echo "Error: Please enter a valid number."
        read PASS_LENGTH
    else
        break
    fi
done

# Ask for encryption key
echo "Enter Key for encrypting the passwords:"
read -s PASSKEY  # -s hides input for security

# Creating an array to capture generated passwords
passwords=()

# Generate passwords according to the length
for i in $(seq 1 $NUMBER_OF_PASSWARD); do
    passwords+=("$(openssl rand -base64 48 | cut -c1-$PASS_LENGTH)")
done

# Display generated passwords
echo "Here are the generated passwords:"
printf "%s\n" "${passwords[@]}"

# Ask user if they want to save the passwords to a file
echo "Do you want to save these passwords to a file? (y/n)"
read choice

if [[ "$choice" == "y" ]]; then
    # Save all passwords to a temporary file
    TEMP_FILE=$OUTPUT_FILE
    printf "%s\n" "${passwords[@]}" > "$TEMP_FILE"

    # Encrypt the file using ccrypt
    ccrypt -e -K "$PASSKEY" "$TEMP_FILE"

    # Remove the plaintext file
    rm -f "$TEMP_FILE"

    echo "Passwords saved securely to $OUTPUT_FILE.cpt"

elif [[ "$choice" == "n" ]]; then
    echo "Passwords not saved."
fi

# Decrypt : ccrypt -d -K "your_key_here" -c passwords.txt.cpt

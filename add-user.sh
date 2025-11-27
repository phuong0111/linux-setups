#!/bin/bash

# ==========================================
#  add-user.sh
#  Create a new user with sudo privileges
#  Usage:
#     ./add-user.sh --username <username> --password <password>
# ==========================================

# --- Parse args ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        --username)
            USERNAME="$2"
            shift 2
            ;;
        --password)
            PASSWORD="$2"
            shift 2
            ;;
        *)
            echo "Error: Unknown argument: $1"
            echo "Usage: ./add-user.sh --username <username> --password <password>"
            exit 1
            ;;
    esac
done

# --- Validate ---
if [[ -z "$USERNAME" || -z "$PASSWORD" ]]; then
    echo "Error: --username and --password are required."
    echo "Usage: ./add-user.sh --username <username> --password <password>"
    exit 1
fi

# --- Require root ---
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with sudo or as root."
    exit 1
fi

# --- Check if user exists ---
if id "$USERNAME" &>/dev/null; then
    echo "User '$USERNAME' already exists."
    exit 1
fi

# --- Create user ---
echo "Creating user '$USERNAME'..."
useradd -m -s /bin/bash "$USERNAME"

# --- Set password ---
echo "$USERNAME:$PASSWORD" | chpasswd

# --- Add sudo privileges ---
usermod -aG sudo "$USERNAME"

echo "User '$USERNAME' created and added to sudo group."
echo "Done!"

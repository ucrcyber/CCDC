#!/bin/bash

#### Start constants

BACKUP_DIR="backup_repo"  # Directory where the repository is stored
BACKUP_FILE="backup.sql"  # Name of file to be stored in $BACKUP_DIR
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_FILE}"
DEFAULTS_FILE="cred.tmp"  # Temporary defaults file used to mysqldump securely
TARGET_FILE="backup_target.txt"  # File containing the commit hash used to restore the DB (cannot be absolute path)

#### End constants

#### Start functions

# Check if a variable is set. If not, output an error and exit.
function val_err()
{
    echo "$1 not set, but required, exiting..." >&2
    exit 1
}

# Check if a command exists. If not, output an error and exit.
function val_cmd()
{
    if ! hash "$1" 2> /dev/null; then
        echo "$1 command is missing. Please install it and retry." >&2
        exit 2
    fi
}

#### End functions


if [ -z $DB_HOST ]; then
    val_err '$DB_HOST'
fi

CRED_BYPASS=0  # Whether or not the current user is root and accessing a local DB

# Require DB username and password only if authentication is needed
#  (authentication can be bypassed if the $DB_HOST == localhost and the user is root)
if [[ $DB_HOST != "localhost" || $EUID -ne 0 ]] ; then
    if [[ -z "$DB_USER" ]]; then
        val_err '$DB_USER'
        elif [[ -z $DB_PASS ]]; then
        val_err '$DB_PASS'
    fi
else
    CRED_BYPASS=1
fi

REQUIRED_CMDS=(git mysql mysqldump sed)
# Make sure the required tools are installed
for cmd in ${REQUIRED_CMDS[@]}; do
    val_cmd "$cmd"
done

# Make backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# A naive, but sufficient way to check if a git repository exists in the directory
if [[ ! -d "${BACKUP_DIR}/.git" ]]; then
    cd "$BACKUP_DIR"
    git init
    cd -
fi

chmod 600 -R "$BACKUP_DIR"

# Next, we dump the DB to a temporary file to see if there is a difference in DB state
#  we pipe the result through sed to remove the last line (which usually contains the timestamp)

echo "===== Dumping Database ====="
if [[ $CRED_BYPASS == 0 ]]; then
    # Tricky part - execute the dump without exposing the password as an argument
    #  to do this, we create a temporary option file and pass it in to mysqldump
    touch "$DEFAULTS_FILE"  # we create an empty file first to prevent it from being accessed before permissions are set
    chmod 600 "$DEFAULTS_FILE"
    cat <<- EOF > $DEFAULTS_FILE
[client]
password=${DB_PASS}
EOF
    echo "wd: $(pwd)"
    mysqldump --defaults-file="$DEFAULTS_FILE" --all-databases -h "$DB_HOST" -u "$DB_USER" | sed "$ d" > "${BACKUP_PATH}.tmp"
    # Debugging line:
    # mysqldump -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" --all-databases | sed "$ d" > "${BACKUP_PATH}.tmp"
else
    # We're privileged, so we can just access the DB directly
    mysqldump --all-databases | sed "$ d" > "${BACKUP_PATH}.tmp"
fi


# Check to see if $BACKUP_PATH exists
if [[ ! -f $BACKUP_PATH ]]; then
    cd "$BACKUP_DIR"
    mv "${BACKUP_FILE}.tmp" "${BACKUP_FILE}"
    git add "$BACKUP_FILE"
    git -c user.name='DB Backup' -c user.email='willshiao@gmail.com' commit -m "Initial DB backup"
    echo "Created initial DB backup"
    git rev-parse HEAD > "../${TARGET_FILE}"
    chmod 600 "../${TARGET_FILE}"
    cd -
    elif diff -q "${BACKUP_PATH}" "${BACKUP_PATH}.tmp"; then
    echo "DB state unchanged"
    # If there's no difference, remove the .tmp file and don't do anything
    rm -f "${BACKUP_PATH}.tmp"
else
    # If there is a difference, warn user, advance to latest git revision and commit
    echo "DIFFERENCE FOUND IN CURRENT DB STATE:"
    diff "${BACKUP_PATH}" "${BACKUP_PATH}.tmp"
    
    cd "$BACKUP_DIR"
    git checkout master
    mv "${BACKUP_FILE}.tmp" "${BACKUP_FILE}"
    git add "$BACKUP_FILE"
    git -c user.name='DB Backup' -c user.email='willshiao@gmail.com' commit -m "DB backup of ${DB_HOST} at $(date +%Y-%m-%d-T%H:%M:%S)"
    echo "Completed DB backup, restoring..."
    
    git checkout "$(cat "$TARGET_FILE")"
    # Restore DB state to target
    if [[ $CRED_BYPASS == 0 ]]; then
        mysql < "$TARGET_FILE"
    else
        mysql --defaults-file="../$DEFAULTS_FILE" --all-databases -h "$DB_HOST" -u "$DB_USER" < "$TARGET_FILE"
    fi
    git checkout master
    cd -
    
    echo "DB Restored!"
fi

# Remove the credentials file if it exists
if [[ -f $DEFAULTS_FILE ]]; then
    rm -f "$DEFAULTS_FILE"
fi

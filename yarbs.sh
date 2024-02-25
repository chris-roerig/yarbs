#!/bin/bash

# Default values
SOURCE="$HOME" # Default source path
BACKUP_DIR="$HOME/Backups" # Default backup directory
SKIP_PATHS=("$HOME/Downloads/ $HOME/Backups/ .cache/ .git/ temp/ $HOME/.local/share/Trash") # Paths to skip
SKIP_EXTENSIONS=("zip") # File extensions to skip
DRY_RUN=true # Dry run flag by default
LIMIT_SIZE_MB=0 # Don't backup files over the limit. Default to no limit

# Parse command-line arguments
while getopts "s:b:p:e:l:d" opt; do
  case $opt in
    s) SOURCE=$OPTARG ;;
    b) BACKUP_DIR=$OPTARG ;;
    p) SKIP_PATHS=$OPTARG ;;
    e) SKIP_EXTENSIONS=$OPTARG ;;
    l) LIMIT_SIZE_MB=$OPTARG ;;
    d) DRY_RUN=true ;;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
  esac
done

# Initialize backup directories and perform initial backup if necessary
initialize_backup_directories() {
    for dir in yearly monthly weekly daily hourly; do
        if [ ! -d "$BACKUP_DIR/$dir" ]; then
            mkdir -p "$BACKUP_DIR/$dir" || { echo "Failed to create directory: $BACKUP_DIR/$dir"; exit 1; }
            echo "Initializing $dir backup..."
            perform_backup "$dir"
        fi
    done
}

# Determine backup type based on current date and time
determine_backup_type() {
    local hour=$(date +%H)
    local day_of_week=$(date +%u) # 1 (Monday) to 7 (Sunday)
    local day_of_month=$(date +%d)
    local month=$(date +%m)

    # Yearly backup on 1st January
    if [ "$month" -eq 1 ] && [ "$day_of_month" -eq 1 ]; then
        echo "yearly"
    # Monthly backup on the 1st of every month
    elif [ "$day_of_month" -eq 1 ]; then
        echo "monthly"
    # Weekly backup on Sundays
    elif [ "$day_of_week" -eq 7 ]; then
        echo "weekly"
    # Daily backup at 2 AM
    elif [ "$hour" -eq 2 ]; then
        echo "daily"
    # Hourly backups on the hour
    else
        echo "hourly"
    fi
}

perform_backup() {
    local backup_type=$1
    local date=$(date +"%Y-%m-%dT%H:%M:%S")
    local dest="$BACKUP_DIR/$backup_type/$date"

    # Print the rsync command
    echo "Running rsync command:"
    echo "rsync $RSYNC_OPTS $SOURCE $dest"

    rsync $RSYNC_OPTS $SOURCE $dest

    if [ "$DRY_RUN" = false ]; then
        rm -f $BACKUP_DIR/$backup_type/latest
        ln -s $dest $BACKUP_DIR/$backup_type/latest
    fi
}

# Manage backup retention
manage_retention() {
    # Get the list of backups, sorted oldest first
    local backups=$(ls -1tr $BACKUP_DIR/$BACKUP_TYPE)

    # Count the number of backups
    local count=$(echo "$backups" | wc -l)

    # Calculate number of backups to delete
    local delete_count=$((count - MAX_BACKUPS))

    if [ $delete_count -gt 0 ]; then
        # List the oldest backups to delete
        local old_backups=$(echo "$backups" | head -n $delete_count)

        # Delete the old backups
        for backup in $old_backups; do
            rm -rf "$BACKUP_DIR/$BACKUP_TYPE/$backup"
        done
    fi
}

# Build rsync options
RSYNC_OPTS="-aP --delete"
if [ "$DRY_RUN" = true ]; then
    RSYNC_OPTS="$RSYNC_OPTS --dry-run"
fi
if [ -n "$SKIP_PATHS" ]; then
    for path in $SKIP_PATHS; do
        RSYNC_OPTS="$RSYNC_OPTS --exclude=$path"
    done
fi
if [ -n "$SKIP_EXTENSIONS" ]; then
    for ext in $SKIP_EXTENSIONS; do
        RSYNC_OPTS="$RSYNC_OPTS --exclude=*.$ext"
    done
fi
if [ "$LIMIT_SIZE_MB" -gt 0 ]; then
    RSYNC_OPTS="$RSYNC_OPTS --max-size=${LIMIT_SIZE_MB}M"
fi

# Initialize directories and perform initial backups if needed
initialize_backup_directories

# Determine backup type and perform backup
BACKUP_TYPE=$(determine_backup_type)
DATE=$(date +"%Y-%m-%dT%H:%M:%S")
DEST="$BACKUP_DIR/$BACKUP_TYPE/$DATE"

# Set MAX_BACKUPS based on the type
case $BACKUP_TYPE in
  hourly)
    MAX_BACKUPS=24  # Keep last 24 hourly backups
    ;;
  daily)
    MAX_BACKUPS=7  # Keep last 7 daily backups
    ;;
  weekly)
    MAX_BACKUPS=4  # Keep last 4 weekly backups
    ;;
  monthly)
    MAX_BACKUPS=12  # Keep last 12 monthly backups
    ;;
  yearly)
    MAX_BACKUPS=5  # Keep last 5 yearly backups
    ;;
esac

# Perform the backup
perform_backup $BACKUP_TYPE

# Manage retention for the specific backup type
manage_retention

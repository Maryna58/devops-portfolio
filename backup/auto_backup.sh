#!/bin/bash

SOURCE_DIR="/c/Users/HP/Desktop/labs/devops-portfolio/source"
BACKUP_DIR="/c/Users/HP/Desktop/labs/devops-portfolio/backup"
LOG_FILE="$BACKUP_DIR/backup.log"
MAX_BACKUPS=5

mkdir -p "$BACKUP_DIR"

if [ ! -d "$SOURCE_DIR" ]; then
    echo "$(date +"%Y-%m-%d %H:%M:%S") - CRITICAL: Source directory $SOURCE_DIR not found!" >> "$LOG_FILE"
    echo "Error: Source directory not found."
    exit 1
fi

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/backup_$TIMESTAMP.tar.gz"

echo "$(date +"%Y-%m-%d %H:%M:%S") - [START] Backing up $SOURCE_DIR..." >> "$LOG_FILE"

if tar -czf "$BACKUP_FILE" -C "$SOURCE_DIR" . >> "$LOG_FILE" 2>&1; then
    echo "$(date +"%Y-%m-%d %H:%M:%S") - [SUCCESS] Created: $BACKUP_FILE" >> "$LOG_FILE"
else
    echo "$(date +"%Y-%m-%d %H:%M:%S") - [FAIL] Backup creation failed!" >> "$LOG_FILE"
    exit 1
fi

# --- CLEAN BACKUP ---
cd "$BACKUP_DIR" || exit

FILES_TO_DELETE=$(ls -1t backup_*.tar.gz 2>/dev/null | tail -n +$((MAX_BACKUPS + 1)))

if [ -n "$FILES_TO_DELETE" ]; then
    echo "$(date +"%Y-%m-%d %H:%M:%S") - [CLEANUP] Found old backups. Removing..." >> "$LOG_FILE"
    
    echo "$FILES_TO_DELETE" | while read -r file; do
        if [ -n "$file" ]; then
            rm -f "$file"
            echo "$(date +"%Y-%m-%d %H:%M:%S") - [DELETED] Removed old file: $file" >> "$LOG_FILE"
        fi
    done
else
    echo "$(date +"%Y-%m-%d %H:%M:%S") - [CLEANUP] No old backups to delete (Total <= $MAX_BACKUPS)." >> "$LOG_FILE"
fi

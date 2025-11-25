#!/bin/bash

CPU_THRESHOLD=80
RAM_THRESHOLD=80
DISK_THRESHOLD=90

TELEGRAM_BOT_TOKEN="8576051167:AAE6L3OkwkL5P8jPKzBDHDZbMt4Wc49SpVw"
TELEGRAM_CHAT_ID="-1003349189005"

send_telegram_alert() {
    local message=$1
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local full_message=" SYSTEM ALERT [$timestamp] %0A$message"
    
    if [ -z "$TELEGRAM_BOT_TOKEN" ]; then
        echo "Error: Token is empty"
        return
    fi

    echo "Attempting to send to Telegram..."

    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
        -d chat_id="$TELEGRAM_CHAT_ID" \
        --data-urlencode "text=$full_message"
    
    echo "" 
}

send_alert() {
    local message=$1
    echo "Sending alert: $message"
    send_telegram_alert "$message"
}

# --- 1. DISK USAGE CHECK ---
DISK_USAGE=$(df -h /c | tail -1 | awk '{print $5}' | sed 's/%//')

if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
    echo "High Disk Usage detected: ${DISK_USAGE}%"
    send_alert "Critical Disk Space on C: ${DISK_USAGE}% used! (Threshold: ${DISK_THRESHOLD}%)"
fi

# --- 2. RAM USAGE CHECK ---
if command -v free &> /dev/null; then
    RAM_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}' | cut -d. -f1)
    if [ "$RAM_USAGE" -gt "$RAM_THRESHOLD" ]; then
        echo "High RAM Usage detected: ${RAM_USAGE}%"
        send_alert "High RAM Usage: ${RAM_USAGE}% (Threshold: ${RAM_THRESHOLD}%)"
    fi
else
    echo "Info: 'free' command not found (likely Windows environment)."
fi

# --- 3. CPU USAGE CHECK ---
if command -v top &> /dev/null; then
    CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print $1}' | cut -d. -f1)

    if [[ "$CPU_IDLE" =~ ^[0-9]+$ ]]; then
        CPU_USAGE=$((100 - CPU_IDLE))
        if [ "$CPU_USAGE" -gt "$CPU_THRESHOLD" ]; then
            echo "High CPU Load detected: ${CPU_USAGE}%"
            send_alert "High CPU Load: ${CPU_USAGE}% (Threshold: ${CPU_THRESHOLD}%)"
        fi
    fi
fi
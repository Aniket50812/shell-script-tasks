#!/bin/bash

# Log file
LOG_FILE="system_monitoring.csv"

# CSV header
echo "Timestamp,CPU_Usage(%),Memory_Usage(%),Disk_Usage(%),Network_RX(KB),Network_TX(KB)" > $LOG_FILE

# Thresholds
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80

# Function to gather system metrics
collect_metrics() {
    # Get CPU usage
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    
    # Get memory usage
    MEMORY_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')

    # Log the data
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    echo "$TIMESTAMP,$CPU_USAGE,$MEMORY_USAGE" >> $LOG_FILE
    
    # Display the metrics
    clear
    echo "System Monitoring Report"
    echo "========================"
    echo "Timestamp: $TIMESTAMP"
    echo "CPU Usage: $CPU_USAGE%"
    echo "Memory Usage: $MEMORY_USAGE%"
    echo "========================"
    
    # Check for alerts
    if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
        echo "Alert: High CPU Usage ($CPU_USAGE%)!"
    fi
    
    if (( $(echo "$MEMORY_USAGE > $MEMORY_THRESHOLD" | bc -l) )); then
        echo "Alert: High Memory Usage ($MEMORY_USAGE%)!"
    fi
}

# Run the monitoring in a loop
while true; do
    collect_metrics
    sleep 2  # Adjust the sleep duration as necessary
done

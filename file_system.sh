#!/bin/bash
#file system monitoring and automatic maintaince

THRESHOLD=80                      
TEMP_DIR="/tmp"                   
LOG_DIR="/var/log"                
ARCHIVE_DIR="/var/log/archive"    
CHECK_INTERVAL=86400              

check_disk_usage() {
    echo "Checking disk usage..."
    df -h

}

check_file_corruption() {
    echo "Checking for file corruption..."
    for file in $(find / -type f); do      #root direct
        if ! [ -e "$file" ]; then
            echo "Corrupted file detected: $file"
        fi
    done
}


run_fsck() {
    echo "Running filesystem check (fsck)..."
    #block devices and file system
    for partition in $(lsblk -o NAME,FSTYPE | awk '$2=="ext4"{print "/dev/"$1}'); do
        echo "Checking $partition..."
        if mountpoint -q "$partition"; then
            echo "$partition is mounted, skipping fsck."
        else
            fsck -y "$partition"
        fi
    done
}

# Function to perform maintenance tasks
perform_maintenance() {
    echo "Performing maintenance tasks..."
  
    find $TEMP_DIR -type f -delete


    find $LOG_DIR -name "*.log" -exec gzip {} \;


    find $LOG_DIR -type f -mtime +30 -exec mv {} $ARCHIVE_DIR \; #Moves log files older than 30 days to the archive directory.
}

# Main script execution
echo "Starting filesystem monitoring script..."
check_disk_usage
check_file_corruption
run_fsck
perform_maintenance
echo "Monitoring completed."





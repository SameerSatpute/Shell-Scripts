#!/bin/bash

# Directory for log files
LOG_DIR="/root/migration/log"
### In this 0.0.0.0 is just the dummy ip #####
# Rsync /var/lib/imap/
echo "Starting rsync for /var/lib/imap/ at $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_DIR/migration.log"
rsync -avrtlH --progress root@0.0.0.0::new_ev/mailbox1/var-lib/ /mailbox1/lib/ >> "$LOG_DIR/migration.log" 2>&1
echo "Finished rsync for /var/lib/imap/ at $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_DIR/migration.log"

# Rsync /var/spool/imap/
echo "Starting rsync for /var/spool/imap/ at $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_DIR/migration.log"
rsync -avrtlH --progress root@0.0.0.0::new_ev/mailbox1/spool/ /mailbox1/spool/ >> "$LOG_DIR/migration.log" 2>&1
echo "Finished rsync for /var/spool/imap/ at $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_DIR/migration.log"
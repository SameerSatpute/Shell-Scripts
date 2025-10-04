#!/bin/bash

# Directory for log files
LOG_DIR="/root/migration/log"

# Rsync /var/lib/imap/
echo "Starting rsync for /var/lib/imap/ at $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_DIR/migration.log"
rsync -avrtlH --progress root@173.120.107.154::new_ev/mailbox1/var-lib/ /mailbox1/lib/ >> "$LOG_DIR/migration.log" 2>&1
echo "Finished rsync for /var/lib/imap/ at $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_DIR/migration.log"

# Rsync /var/spool/imap/
echo "Starting rsync for /var/spool/imap/ at $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_DIR/migration.log"
rsync -avrtlH --progress root@173.120.107.154::new_ev/mailbox1/spool/ /mailbox1/spool/ >> "$LOG_DIR/migration.log" 2>&1
echo "Finished rsync for /var/spool/imap/ at $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_DIR/migration.log"
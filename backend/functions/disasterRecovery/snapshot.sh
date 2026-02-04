#!/bin/bash
# disaster_recovery.sh
# Automated snapshot script for oblns Infrastructure

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="/backups/$TIMESTAMP"
S3_BUCKET="s3://oblns-backups-libya"

mkdir -p $BACKUP_DIR

echo "🚀 Starting Backup: $TIMESTAMP"

# 1. Appwrite DB Snapshot (MariaDB/Postgres)
docker exec appwrite-mariadb mysqldump --all-databases -u root -pPassword > $BACKUP_DIR/appwrite_db.sql

# 2. External Postgres Snapshot (Financial Data)
docker exec oblns-postgres pg_dump -U admin oblns_financials > $BACKUP_DIR/financials.sql

# 3. Appwrite Storage Volume (KYC Documents)
tar -czf $BACKUP_DIR/storage.tar.gz /var/lib/docker/volumes/appwrite-storage

# 4. Upload to S3 (requires aws-cli or rclone)
aws s3 sync $BACKUP_DIR $S3_BUCKET/$TIMESTAMP

# 5. Cleanup local old backups
find /backups/ -type d -mtime +7 -exec rm -rf {} +

echo "✅ Backup Completed and Uploaded to S3."

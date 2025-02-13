#!/bin/bash

LOG_DIR="$HOME/.local/state/backups"
LOG_FILE="$LOG_DIR/backup_$(date +"%Y%m%d_%H%M%S").log"
RETRY_LIMIT=3

mkdir -p "$LOG_DIR"

# Redirect all output (stdout and stderr) to the log file
exec > >(tee -a "$LOG_FILE") 2>&1

log() {
  echo "$(date +"%Y-%m-%d %H:%M:%S") - $1"
}

fail() {
  log "Backup failed!"
  exit 1
}

retry() {
  local n=1
  local max=$RETRY_LIMIT
  local delay=5
  local cmd="$*"

  while true; do
    log "Attempt $n/$max: $cmd"
    $cmd && break || {
      if [[ $n -lt $max ]]; then
        ((n++))
        log "Command failed. Retrying in $delay seconds..."
        sleep $delay
      else
        log "Command failed after $n attempts."
      fi
    }
  done
}

perform_rsync() {
  src=$1
  dest=$2
  retry rsync -ach --no-perms --no-owner --no-group --no-times --ignore-errors --partial --no-links --exclude 'mnt/' --exclude=".conan2" --exclude='.local/' --exclude='.cache/' --exclude='.git/' --exclude='*Steam*' --exclude='samba/' --exclude '*/samba/' --exclude='lost+found/' --exclude='*/lost+found/' "$src" "$dest"
}

perform_backup() {
  if mountpoint -q /mnt/usb; then
    log "Drive is mounted to /mnt/usb. Starting backup."

    # Perform rsync operations with retry logic
    perform_rsync "/home/ryan" "/mnt/usb/"
    log "Local backup completed successfully."

  #   # Mount Google Drive if not already mounted
  #   if ! mountpoint -q /home/ryan/mnt/gdrive; then
  #     retry "rclone mount gdrive: /home/ryan/mnt/gdrive --vfs-cache-mode writes &"
  #     sleep 10
  #   fi
  #
  #   # Backup Google Drive to USB
  #   perform_rsync "/home/ryan/mnt/gdrive/" "/mnt/usb/gdrive/"
  #
  #   # Mount Google Photos if not already mounted
  #   if ! mountpoint -q /home/ryan/mnt/gphotos; then
  #     retry "rclone mount gphotos: /home/ryan/mnt/gphotos --vfs-cache-mode writes &"
  #     sleep 10
  #   fi
  #
  #   # Backup Google Drive to USB
  #   perform_rsync "/home/ryan/mnt/gphotos/" "/mnt/usb/gphotos/"
  #
  #   # Mount UKY Google Drive if not already mounted
  #   if ! mountpoint -q /home/ryan/mnt/uky_gdrive; then
  #     retry "rclone mount uky_gdrive: /home/ryan/mnt/uky_gdrive --vfs-cache-mode writes &"
  #     sleep 10
  #   fi
  #
  #   # Backup Google Drive to USB
  #   perform_rsync "/home/ryan/mnt/uky_gdrive/" "/mnt/usb/uky_gdrive/"
  #
  #   # Mount UKY OneDrive if not already mounted
  #   if ! mountpoint -q /home/ryan/mnt/uky_onedrive; then
  #     retry "rclone mount uky_onedrive: /home/ryan/mnt/uky_onedrive --vfs-cache-mode writes &"
  #     sleep 10
  #   fi
  #
  #   # Backup UKY OneDrive to USB
  #   perform_rsync "/home/ryan/mnt/uky_onedrive" "/mnt/usb/uky_gdrive/"
  #
  #   log "Cloud backup completed successfully."
  #   exit 0
  # else
  #   log "Drive is not mounted to /mnt/usb. Backup aborted."
  #   exit 1
  fi
}

perform_backup

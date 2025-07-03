#!/bin/bash

# --- Config ---
SHARE="//192.168.2.202/zfs-backups"
MOUNTPOINT="/mnt/samba/backups"
CRED_FILE="/root/.smbcredentials"
#---- backup file config ---
SRC_FILE="/media/tgsata/MyVolume.hc"
FILENAME="$(basename "${SRC_FILE%.*}")"
EXT="${SRC_FILE##*.}"
DATE_TAG=$(date +%Y-%m-%d-%H%M)
DEST_FILE="$MOUNTPOINT/tgsata/${FILENAME}-backup-${DATE_TAG}.${EXT}"

# --- Flags ---
REPLACE=false
DO_SYNC=false

for arg in "$@"; do
    case "$arg" in
    --replace)
        REPLACE=true
        ;;
    --sync)
        DO_SYNC=true
        ;;
    esac
done

# --- Mount SMB share ---
if mountpoint -q "$MOUNTPOINT"; then
    echo "Share already mounted at $MOUNTPOINT"
else
    echo "Creating mount point if needed..."
    sudo mkdir -p "$MOUNTPOINT"

    echo "Mounting $SHARE to $MOUNTPOINT"
    sudo mount -t cifs "$SHARE" "$MOUNTPOINT" \
        -o credentials="$CRED_FILE",uid=$(id -u),gid=$(id -g),file_mode=0777,dir_mode=0777,_netdev

    if [ $? -ne 0 ]; then
        echo "Mount failed"
        exit 1
    fi

    echo "Mount successful"
fi

# --- Rsync function ---
rsync_file() {
    if [ "$REPLACE" = true ]; then
        echo "Replacing existing file (fresh copy)..."
        rsync -avh --progress --delete "$SRC_FILE" "$DEST_FILE"
    else
        echo "Resuming file copy if interrupted..."
        rsync -avh --progress --partial --append-verify "$SRC_FILE" "$DEST_FILE"
    fi
}

# --- Optional sync ---
if [ "$DO_SYNC" = true ]; then
    rsync_file
else
    echo "Skipping sync (use --sync to enable)"
fi

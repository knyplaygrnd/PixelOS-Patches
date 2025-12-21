#!/bin/bash

# --- CONFIG ---
GITHUB_USER="knyplaygrnd"
REPO_NAME="PixelOS-Patches"
BRANCH="sixteen-qpr1"
BASE_URL="https://raw.githubusercontent.com/$GITHUB_USER/$REPO_NAME/$BRANCH"

PATCHES=(
"bootable_recovery/0001-recovery-Always-consider-builds-to-be-debuggable.patch"
"device_lineage_sepolicy/0001-common-Always-run-recovery-in-permissive-domain.patch"
"system_sepolicy/0001-Allow-permissive-domains-on-user-builds-for-recovery.patch"
"system_sepolicy/0002-Allow-permissive-backuptool-domain-on-user-builds.patch"
"system_sepolicy/0003-Allow-adb-root-on-user-builds.patch"
"system_sepolicy/0004-Make-su-domain-permissive-on-user-builds.patch"
)
# --------------

ROOT=$(pwd)

echo "[*] Starting Patch Process..."

for remote_path in "${PATCHES[@]}"; do
    folder=$(dirname "$remote_path")
    file=$(basename "$remote_path")
    target_dir="${folder//_//}"

    if [ ! -d "$target_dir" ]; then
        echo "[!] Directory not found: $target_dir"
        continue
    fi

    curl -sL "$BASE_URL/$remote_path" -o "/tmp/$file" || { echo "[!] Download error: $file"; continue; }

    cd "$target_dir" || continue

    if git apply --check -R "/tmp/$file" &>/dev/null; then
        echo "[i] Skipped (Already applied): $file"
    elif git apply --check "/tmp/$file" &>/dev/null; then
        git apply "/tmp/$file"
        echo "[+] Applied: $file"
    else
        echo "[-] Failed (Conflict): $file"
    fi

    cd "$ROOT" || exit
    rm -f "/tmp/$file"
done

echo "[*] Done."

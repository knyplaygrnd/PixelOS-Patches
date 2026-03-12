#!/bin/bash

# --- CONFIG ---
GITHUB_USER="knyplaygrnd"
REPO_NAME="PixelOS-Patches"
BRANCH="sixteen-qpr1"
BASE_URL="https://raw.githubusercontent.com/$GITHUB_USER/$REPO_NAME/$BRANCH"

PATCHES=(
"bootable_recovery/0001-Revert-recovery-Make-recovery-usable-on-user-builds.patch"
"bootable_recovery/0002-recovery-Make-recovery-usable-on-user-builds.patch"
"bootable_recovery/0003-recovery-allow-formatting-mounting-system-on-user-bu.patch"
"bootable_recovery/0004-recovery-Skip-verifying-packages-altogether.patch"
"bootable_recovery/0005-recovery-Always-consider-builds-to-be-debuggable.patch"
"bootable_recovery/0006-install-Do-not-check-ro.build.tags-on-user-builds.patch"
"device_lineage_sepolicy/0001-Revert-Make-backuptool-permissive-only-in-non-user-b.patch"
"device_lineage_sepolicy/0002-common-Always-run-recovery-in-permissive-domain.patch"
"frameworks_base/0001-SystemUI-Enable-landscape-lockscreen-flag.patch"
"hardware_qcom-caf_sm8250_display/0001-sdm-hwc-Allow-enabling-doze-mode-support-with-a-prop.patch"
"packages_apps_Settings/0001-Settings-Enable-glanceble-hub-for-all.patch"
"system_sepolicy/0001-Allow-permissive-domains-on-user-builds-for-recovery.patch"
"system_sepolicy/0002-Allow-permissive-backuptool-domain-on-user-builds.patch"
"system_sepolicy/0003-Allow-adb-root-on-user-builds.patch"
"system_sepolicy/0004-Make-su-domain-permissive-on-user-builds.patch"
"system_sepolicy/0005-sepolicy-Allow-system-app-to-access-sysfs_leds.patch"
"system_sepolicy/0006-sepolicy-Allow-permissive-in-recovery-on-user-builds.patch"
"system_sepolicy/0007-fixup-Make-su-domain-permissive-on-user-builds.patch"
"vendor_custom/0001-overlay-Enable-UMO-on-the-glanceable-hub-when-media-is.patch"
"vendor_custom/0002-overlay-Enable-Lockscreen-widgets-settings-on-mobile.patch"
)
# --------------

ROOT=$(pwd)

echo "[*] Starting Patch Process..."

for remote_path in "${PATCHES[@]}"; do
    folder=$(dirname "$remote_path")
    file=$(basename "$remote_path")
    target_dir="${folder//_//}"
    tmp_patch="/tmp/$file"

    if [ ! -d "$target_dir" ]; then
        echo "[!] Directory not found: $target_dir"
        continue
    fi

    # Download
    curl -sL "$BASE_URL/$remote_path" -o "$tmp_patch" || { echo "[!] Download error: $file"; continue; }

    cd "$target_dir" || continue

    # Try applying with git am
    # We silence output to keep it clean
    if git am "$tmp_patch" > /dev/null 2>&1; then
        echo "[+] Applied: $file"
    else
        # If it fails, we must abort to remove the .git/rebase-apply state
        git am --abort > /dev/null 2>&1
        echo "[-] Failed (Conflict or already applied): $file"
    fi

    cd "$ROOT" || exit
    rm -f "$tmp_patch"
done

echo "[*] Done."

#!/bin/bash

SCRIPT_DIR="$(dirname "$0")"
APPLY_SH="$SCRIPT_DIR/apply.sh"

mapfile -t FOUND < <(find "$SCRIPT_DIR" -name "*.patch" | sed "s|$SCRIPT_DIR/||" | sort)

if [ ${#FOUND[@]} -eq 0 ]; then
    echo "[-] No patches found."
    exit 1
fi

echo "[*] Found ${#FOUND[@]} patch(es)."

NEW_BLOCK='PATCHES=(\n'
for p in "${FOUND[@]}"; do
    NEW_BLOCK+="\"$p\"\n"
done
NEW_BLOCK+=')'

cp "$APPLY_SH" "${APPLY_SH}.bak"

python3 - "$APPLY_SH" "$NEW_BLOCK" <<'PYEOF'
import sys, re
path, block = sys.argv[1], sys.argv[2]
with open(path, 'r') as f: c = f.read()
with open(path, 'w') as f: f.write(re.sub(r'PATCHES=\(.*?\)', block, c, flags=re.DOTALL))
print("[+] apply.sh updated.")
PYEOF

#!/bin/bash
# ============================================================
#  sync-from-web.sh
#  Copies the latest web files from the OK Music web project
#  into www/ and runs cap sync to update both native projects.
# ============================================================

set -e
SRC="/Users/emmanuelleveille/Claude/Projects/OK Music/publish"
DST="$(dirname "$0")/www"

echo "→ Copying web assets from publish/ …"

files=(
  community.html:index.html
  community.css:community.css
  community.js:community.js
  community-data.js:community-data.js
  community-marketplace.js:community-marketplace.js
  community-wallet.js:community-wallet.js
  community-contests.js:community-contests.js
  community-account.js:community-account.js
  community-calls.js:community-calls.js
  community-dispatcher.js:community-dispatcher.js
  community-listeners.js:community-listeners.js
  community-dj.js:community-dj.js
  firebase-init.js:firebase-init.js
  dj-mixer.html:dj-mixer.html
  dj-mixer.css:dj-mixer.css
  dj-mixer.js:dj-mixer.js
)

for pair in "${files[@]}"; do
  src_file="${pair%%:*}"
  dst_file="${pair##*:}"
  cp "$SRC/$src_file" "$DST/$dst_file"
  echo "   ✓ $src_file → $dst_file"
done

# Copy audio folder
rsync -a --delete "$SRC/audio/" "$DST/audio/" 2>/dev/null || true

# Re-inject native-auth.js into index.html (in case it was overwritten)
if ! grep -q "native-auth.js" "$DST/index.html"; then
  sed -i '' 's|<script src="community-dj.js[^"]*"></script>|&\n  <script src="native-auth.js"></script>|' "$DST/index.html"
  echo "   ✓ native-auth.js injection ensured"
fi

echo ""
echo "→ Running cap sync …"
cd "$(dirname "$0")"
npx cap sync

echo ""
echo "✓ Done. Open Android Studio or Xcode and rebuild."

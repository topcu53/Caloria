#!/usr/bin/env bash
# Play Store için upload keystore oluşturur (bir kez çalıştırın).
set -euo pipefail
cd "$(dirname "$0")/.."

KEYSTORE="android/upload-keystore.jks"
PROPS="android/key.properties"

if [[ -f "$KEYSTORE" ]]; then
  echo "Keystore zaten var: $KEYSTORE"
  exit 0
fi

echo "=== Caloria — Android imzalama kurulumu ==="
echo "Bu şifreleri GÜVENLİ bir yere kaydedin. Kaybederseniz uygulama güncelleyemezsiniz."
echo ""
read -rsp "Keystore şifresi: " STORE_PASS
echo ""
read -rsp "Key şifresi (Enter = aynı): " KEY_PASS
echo ""
KEY_PASS="${KEY_PASS:-$STORE_PASS}"

keytool -genkey -v \
  -keystore "$KEYSTORE" \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload \
  -storepass "$STORE_PASS" \
  -keypass "$KEY_PASS" \
  -dname "CN=Caloria, OU=Mobile, O=Caloria, L=Istanbul, C=TR"

cat > "$PROPS" <<EOF
storePassword=$STORE_PASS
keyPassword=$KEY_PASS
keyAlias=upload
storeFile=upload-keystore.jks
EOF

echo ""
echo "Tamam:"
echo "  $KEYSTORE"
echo "  $PROPS"
echo ""
echo "Sonraki adım: ./scripts/build_play_aab.sh"

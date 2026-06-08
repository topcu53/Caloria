#!/usr/bin/env bash
# Google Play için imzalı App Bundle (.aab) üretir.
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ ! -f android/key.properties ]] || [[ ! -f android/upload-keystore.jks ]]; then
  echo "Önce imzalama kurun: ./scripts/setup_android_signing.sh"
  exit 1
fi

if [[ ! -f dart_defines.json ]]; then
  echo "dart_defines.json yok. admob_config.json + .env ile oluşturun."
  exit 1
fi

echo "==> flutter pub get"
flutter pub get

echo "==> Release App Bundle"
flutter build appbundle --release --dart-define-from-file=dart_defines.json

AAB="build/app/outputs/bundle/release/app-release.aab"
if [[ -f "$AAB" ]]; then
  ls -lh "$AAB"
  echo ""
  echo "Play Console'a yüklenecek dosya:"
  echo "  $(pwd)/$AAB"
else
  echo "AAB oluşturulamadı."
  exit 1
fi

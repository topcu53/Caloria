#!/usr/bin/env bash
# Mağaza derlemesi — önce dart_defines.json oluşturun (dart_defines.example.json).
set -euo pipefail
cd "$(dirname "$0")/.."

DEFINES_FILE="${1:-dart_defines.json}"
if [[ ! -f "$DEFINES_FILE" ]]; then
  echo "Hata: $DEFINES_FILE bulunamadı."
  echo "cp dart_defines.example.json dart_defines.json && değerleri doldurun"
  exit 1
fi

echo "==> flutter pub get"
flutter pub get

echo "==> Android App Bundle"
flutter build appbundle --release --dart-define-from-file="$DEFINES_FILE"

echo "==> iOS (codesign olmadan IPA iskeleti)"
flutter build ipa --release --dart-define-from-file="$DEFINES_FILE" --no-codesign

echo ""
echo "Çıktılar:"
echo "  Android: build/app/outputs/bundle/release/app-release.aab"
echo "  iOS:     build/ios/ipa/ (Xcode ile imzalayıp yükleyin)"

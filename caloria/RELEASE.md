# Caloria — Mağaza yayın rehberi

## Mağaza görselleri

Hazır dosyalar: `assets/store/`

| Dosya | Nereye |
|-------|--------|
| `google_play_icon_512x512.png` | Play Console → Uygulama ikonu |
| `google_play_feature_graphic_1024x500.png` | Play Console → Öne çıkan grafik |
| `app_store_icon_1024x1024.png` | App Store Connect → App Icon |

## Yayın öncesi kontrol listesi

- [ ] Firebase Console: Email/Password auth açık
- [ ] Firestore güvenlik kuralları production için sıkı
- [ ] AdMob: gerçek uygulama + reklam birimleri oluşturuldu
- [ ] Gemini API anahtarı kısıtlamalı (Android/iOS bundle + API limit)
- [ ] `dart_defines.json` dolduruldu (repoya eklenmez)
- [ ] Android `key.properties` + upload keystore hazır
- [ ] iOS: Apple Developer, App Store Connect, provisioning profile
- [ ] Gizlilik politikası URL (Play + App Store zorunlu)
- [ ] Ekran görüntüleri ve mağaza açıklamaları

## Gizli anahtarlar

Geliştirme için `.env` (gitignore). Mağaza derlemesi için:

```bash
cp dart_defines.example.json dart_defines.json
# Tüm değerleri doldurun
```

Derleme:

```bash
chmod +x scripts/build_release.sh
./scripts/build_release.sh dart_defines.json
```

Tek komut:

```bash
flutter build appbundle --release --dart-define-from-file=dart_defines.json
flutter build ipa --release --dart-define-from-file=dart_defines.json
```

## AdMob (3 yer)

1. `dart_defines.json` — banner + interstitial birimleri
2. **Android** `android/gradle.properties` veya komut satırı:
   ```properties
   ADMOB_APP_ID=ca-app-pub-XXXXXXXX~YYYYYYYY
   ```
   (`AndroidManifest` placeholder `${admobAppId}` bunu kullanır)
3. **iOS** `ios/Runner/Info.plist` → `GADApplicationIdentifier` (App ID ile aynı)

Release modda test reklam ID’leri kullanılmaz; tanımlı değilse reklamlar kapalı kalır.

## Android imzalama

```bash
keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
cp android/key.properties.example android/key.properties
# storeFile yolunu ve şifreleri düzenleyin
```

Play Console → Yeni uygulama → `app-release.aab` yükleyin.

## iOS

1. Xcode’da `Runner` → Signing & Capabilities → Team seçin
2. Bundle ID: `com.buraktopcu.caloria`
3. `Info.plist` içinde `GADApplicationIdentifier` gerçek App ID
4. Archive → Distribute App → App Store Connect

Crashlytics sembol yükleme script’i debug için `exit 0`; tam sembol için Firebase dokümantasyonuna bakın.

## Sürüm artırma

`pubspec.yaml`:

```yaml
version: 1.0.1+2   # 1.0.1 = kullanıcıya görünen, +2 = build number
```

## Firebase

`firebase_options.dart` ve `google-services.json` / `GoogleService-Info.plist` projeye özel olmalı. Farklı ortam için FlutterFire CLI ile yeniden yapılandırın.

## Optimizasyonlar (bu sürüm)

- Release: R8 minify + shrink resources (Android)
- Kullanılmayan paketler kaldırıldı (RevenueCat, cropper, shimmer, vb.)
- Debug loglar release’te kapalı (`app_log`)
- Test AdMob yalnızca debug modda

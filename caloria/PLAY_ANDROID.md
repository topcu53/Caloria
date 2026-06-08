# Caloria — Google Play yayın rehberi

## Uygulama bilgileri

| Alan | Değer |
|------|--------|
| Paket adı | `com.buraktopcu.calori` |
| Sürüm | `1.0.0` (build `1`) |
| Min Android | 7.0 (API 24) |
| AdMob App ID | `ca-app-pub-6085407673736182~9241529376` |

---

## Adım 1 — İmzalama (bir kez)

Terminalde proje kökünde:

```bash
chmod +x scripts/setup_android_signing.sh scripts/build_play_aab.sh
./scripts/setup_android_signing.sh
```

Şifreleri **mutlaka kaydedin** (1Password, Notes vb.). Kaybederseniz aynı uygulamayı güncelleyemezsiniz.

---

## Adım 2 — AAB derle

```bash
./scripts/build_play_aab.sh
```

Çıktı:

`build/app/outputs/bundle/release/app-release.aab`

Bu dosyayı Play Console'a yüklersiniz.

---

## Adım 3 — Play Console

1. [Google Play Console](https://play.google.com/console) → **Uygulama oluştur**
2. **Uygulama adı:** Caloria
3. **Varsayılan dil:** Türkçe

### Mağaza girişi (Ana mağaza)

| Alan | Dosya / metin |
|------|----------------|
| Uygulama adı | Caloria |
| Kısa açıklama (80 karakter) | AI ile yemek analizi, kalori ve makro takibi. Su hatırlatıcısı dahil. |
| Tam açıklama | Aşağıdaki şablon |
| Uygulama ikonu | `assets/store/google_play_icon_512x512.png` |
| Öne çıkan grafik | `assets/store/google_play_feature_graphic_1024x500.png` |
| Ekran görütüntüleri | Telefon + tablet (en az 2 telefon) |

**Tam açıklama şablonu:**

```
Caloria ile beslenmeni kolayca takip et.

• AI destekli yemek analizi — fotoğraf çek, kalori ve makroları öğren
• Günlük kalori, protein, karbonhidrat ve yağ takibi
• Su içme hatırlatıcısı
• Kilo ve beslenme grafikleri
• Geçmiş günlerin kayıtları
• Günlük öğün önerileri

Hedeflerini belirle, ilerlemeni izle, sağlıklı alışkanlıklar edin.
```

### Gizlilik politikası (zorunlu)

Bir web sayfası URL’si gerekir. Örnek içerik konuları:

- Toplanan veriler: e-posta, profil, yemek kayıtları, Firebase Analytics
- Kamera: yalnızca yemek fotoğrafı analizi
- Üçüncü taraflar: Firebase, Google AdMob, Gemini API

(GitHub Pages, Notion public page veya kendi sitenizde yayınlayın.)

### Uygulama içeriği

- **Reklam:** Evet (AdMob)
- **Uygulama erişimi:** Hesap gerekli (e-posta veya misafir)
- **Veri güvenliği formu:** E-posta, sağlık/beslenme verileri, fotoğraf → Firebase’de saklanır

### Test / Production

1. **Internal testing** (iç test) — önce buraya AAB yükleyin, kendiniz test edin
2. Sorun yoksa **Production** → incelemeye gönderin

---

## Adım 4 — AdMob mağaza bağlantısı

AdMob → Caloria Android → **Mağaza ekle** → paket: `com.buraktopcu.calori`

Play’de yayınlandıktan sonra “sınırlı reklam” uyarısı genelde kalkar.

---

## Adım 5 — Firebase (kontrol)

- [Firebase Console](https://console.firebase.google.com) → Authentication → **Email/Password** açık
- Firestore kuralları production için gözden geçirilmeli

---

## Sonraki güncellemeler

`pubspec.yaml`:

```yaml
version: 1.0.1+2   # +2 her yüklemede artmalı
```

Sonra tekrar `./scripts/build_play_aab.sh`

---

## Sık hatalar

| Hata | Çözüm |
|------|--------|
| Debug imzalı AAB | `setup_android_signing.sh` çalıştırın |
| versionCode çakışması | `pubspec.yaml` içinde `+` numarasını artırın |
| AdMob onay bekliyor | AdMob hesap onayı + mağaza bağlantısı |
| Gemini çalışmıyor | `dart_defines.json` / `.env` içinde API key |

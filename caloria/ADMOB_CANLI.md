# Canlı reklamlar (Test Ad kaldırıldı)

Kod artık **Google test reklam birimlerini kullanmıyor**. Canlı reklam için AdMob’da oluşturduğun **reklam birimi kimliklerini** projeye eklemen şart.

## 1. AdMob’da birim oluştur

Her platform için **2 birim**:

| Platform | Banner | Geçiş (Interstitial) |
|----------|--------|----------------------|
| Caloria Android | Reklam birimi ekle → Banner | Geçiş |
| Caloria iOS | Reklam birimi ekle → Banner | Geçiş |

Kimlik formatı: `ca-app-pub-6085407673736182/1234567890` (**/** ile biter)

## 2. `admob_config.json` doldur

Proje kökündeki `admob_config.json` dosyasını aç, boş alanlara yapıştır:

```json
"ADMOB_BANNER_ANDROID": "ca-app-pub-6085407673736182/...",
"ADMOB_INTERSTITIAL_ANDROID": "ca-app-pub-6085407673736182/...",
"ADMOB_BANNER_IOS": "ca-app-pub-6085407673736182/...",
"ADMOB_INTERSTITIAL_IOS": "ca-app-pub-6085407673736182/..."
```

## 3. Uygulamayı yeniden başlat

```bash
flutter run
```

Hot reload yetmez.

## Hâlâ “Test Ad” görüyorsan

- **Emülatör** çoğu zaman test etiketi gösterir; **gerçek telefonda** dene.
- AdMob’da cihazı test cihazı olarak eklemediğinden emin ol.
- Play / App Store mağazası bağlı değilse gelir **sınırlı** olabilir (AdMob uyarısı normal).

## Para kazanma

- Uygulama yayında + mağaza AdMob’a bağlı
- Gerçek kullanıcı trafiği
- AdMob hesabı ödeme bilgileri tamam

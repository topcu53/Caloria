# Caloria

AI destekli kalori ve beslenme takip uygulaması (Flutter · Firebase · Gemini).

## Geliştirme

```bash
cp .env.example .env
# GEMINI_API_KEY ve isteğe bağlı AdMob değerlerini doldurun

flutter pub get
flutter run
```

## Mağaza derlemesi

Ayrıntılı adımlar: **[RELEASE.md](RELEASE.md)**

```bash
cp dart_defines.example.json dart_defines.json
./scripts/build_release.sh
```

## Paket kimliği

| Platform | ID |
|----------|-----|
| Android | `com.buraktopcu.calori` |
| iOS | `com.buraktopcu.caloria` |

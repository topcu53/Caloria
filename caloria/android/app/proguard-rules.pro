# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn com.google.android.play.core.**

# Firebase
-keepattributes *Annotation*
-keep class com.google.firebase.** { *; }

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }

# Gson (Firebase / network)
-keepattributes Signature
-keepattributes EnclosingMethod

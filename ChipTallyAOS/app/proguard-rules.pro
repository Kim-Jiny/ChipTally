# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.kts.

# Keep Gson serialized model classes
-keep class com.chiptally.data.model.** { *; }
-keep class com.chiptally.domain.model.** { *; }

# Gson
-keepattributes Signature
-keepattributes *Annotation*

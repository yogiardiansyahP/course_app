# Jangan warning java.util
-dontwarn java.util.**

# Keep semua class java.util agar tidak dioptimasi R8 terlalu agresif
-keep class java.util.** { *; }

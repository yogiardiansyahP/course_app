plugins {
    id("com.android.application")
<<<<<<< HEAD
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
=======
    id("org.jetbrains.kotlin.android")
>>>>>>> 1ead78e (perubahan drastis)
    id("dev.flutter.flutter-gradle-plugin")
}

android {
<<<<<<< HEAD
    namespace = "com.example.project_akhir_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
=======
    namespace = "com.codeIn.course"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"
>>>>>>> 1ead78e (perubahan drastis)

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
<<<<<<< HEAD
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.project_akhir_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
=======
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.codeIn.course"
        minSdk = 21
        targetSdk = 35
>>>>>>> 1ead78e (perubahan drastis)
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
<<<<<<< HEAD
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
=======
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
>>>>>>> 1ead78e (perubahan drastis)
        }
    }
}

flutter {
    source = "../.."
}

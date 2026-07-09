plugins {
    id("com.android.application")
    id("kotlin-android")

    // Flutter Gradle Plugin
    id("dev.flutter.flutter-gradle-plugin")
}

android {

    namespace = "com.example.panic_detector_ai"

    compileSdk = flutter.compileSdkVersion

    // Stable NDK version
    ndkVersion = "27.0.12077973"

    compileOptions {

        sourceCompatibility =
            JavaVersion.VERSION_11

        targetCompatibility =
            JavaVersion.VERSION_11
    }

    kotlinOptions {

        jvmTarget =
            JavaVersion.VERSION_11.toString()
    }

    defaultConfig {

        applicationId =
            "com.example.panic_detector_ai"

        minSdk =
            flutter.minSdkVersion

        targetSdk =
            flutter.targetSdkVersion

        versionCode =
            flutter.versionCode

        versionName =
            flutter.versionName
    }

    buildTypes {

        release {

            signingConfig =
                signingConfigs.getByName("debug")
        }
    }
}

flutter {

    source = "../.."
}
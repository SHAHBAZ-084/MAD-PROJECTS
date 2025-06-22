plugins {
    id("com.android.application")
    kotlin("android")
}

android {
    compileSdk = 33

    defaultConfig {
        applicationId = "com.example.multiplication_game"
        minSdk = 21
        targetSdk = 33
        versionCode = 1
        versionName
        = "1.0"
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
        }
    }
}

dependencies {
    implementation("io.realm.kotlin:library-base:1.12.0")
    implementation(kotlin("stdlib"))
}
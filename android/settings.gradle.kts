pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    val flutterGradlePlugin = file("$flutterSdkPath/packages/flutter_tools/gradle")
    val writableFlutterGradlePlugin =
        if (flutterGradlePlugin.canWrite()) {
            flutterGradlePlugin
        } else {
            val copy = file("build/flutter_sdk/packages/flutter_tools/gradle")
            val engineVersion = file("$flutterSdkPath/bin/internal/engine.version")
            val engineVersionCopy = file("build/flutter_sdk/bin/internal/engine.version")
            if (!copy.exists() || !engineVersionCopy.exists()) {
                flutterGradlePlugin.copyRecursively(copy, overwrite = true)
                copy.resolve(".gradle").deleteRecursively()
                engineVersionCopy.parentFile.mkdirs()
                engineVersion.copyTo(engineVersionCopy, overwrite = true)
            }
            copy
        }

    includeBuild(writableFlutterGradlePlugin.path)

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")

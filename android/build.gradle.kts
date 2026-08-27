allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    plugins.withId("com.android.library") {
        dependencies {
            add("compileOnly", "org.checkerframework:checker-qual:3.48.1")
        }
    }
    plugins.withId("com.android.application") {
        dependencies {
            add("compileOnly", "org.checkerframework:checker-qual:3.48.1")
        }
    }
    configurations.configureEach {
        resolutionStrategy {
            force("org.checkerframework:checker-qual:3.48.1")
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    val applySdkConfig: (Project) -> Unit = { prj ->
        val androidExt = prj.extensions.findByName("android")
        if (androidExt != null) {
            try {
                val setCompileSdk = androidExt.javaClass.methods.firstOrNull {
                    it.name == "setCompileSdk" && it.parameterCount == 1
                }
                setCompileSdk?.invoke(androidExt, 36)
                val compileSdkVersion = androidExt.javaClass.methods.firstOrNull {
                    it.name == "compileSdkVersion" && it.parameterCount == 1 && it.parameterTypes[0] == java.lang.Integer.TYPE
                }
                compileSdkVersion?.invoke(androidExt, 36)
            } catch (_: Throwable) {}
        }
    }

    if (project.state.executed) {
        applySdkConfig(project)
    } else {
        project.afterEvaluate {
            applySdkConfig(project)
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

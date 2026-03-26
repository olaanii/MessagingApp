allprojects {
    repositories {
        google()
        mavenCentral()
    }

    tasks.withType<JavaCompile> {
        options.compilerArgs.add("-Xlint:deprecation")
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
    project.evaluationDependsOn(":app")
}

// Workaround: AGP 8.11.x lint / extractDebugAnnotations crash with IntelliJ
// classpath errors in plugin subprojects. Those tasks are disabled below.
// AGP still wires syncDebugLibJars to typedefs.txt from extract*Annotations;
// stub empty typedefs so Gradle 8 input validation and that task succeed.
fun org.gradle.api.Project.ensureStubTypedefFiles() {
    if (!plugins.hasPlugin("com.android.library")) return
    listOf(
        "intermediates/annotations_typedef_file/debug/extractDebugAnnotations/typedefs.txt",
        "intermediates/annotations_typedef_file/release/extractReleaseAnnotations/typedefs.txt",
    ).forEach { relative ->
        val f = layout.buildDirectory.file(relative).get().asFile
        f.parentFile.mkdirs()
        if (!f.exists()) f.writeText("")
    }
}

subprojects {
    if (state.executed) {
        ensureStubTypedefFiles()
    } else {
        afterEvaluate { ensureStubTypedefFiles() }
    }
}

gradle.projectsEvaluated {
    rootProject.subprojects.forEach { it.ensureStubTypedefFiles() }
}

subprojects {
    tasks.configureEach {
        if (name.contains("Lint", ignoreCase = true) ||
            name.contains("extractDebugAnnotations", ignoreCase = true) ||
            name.contains("extractReleaseAnnotations", ignoreCase = true)
        ) {
            enabled = false
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

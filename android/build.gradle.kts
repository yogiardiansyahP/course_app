allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

<<<<<<< HEAD
=======
val kotlinVersion = "2.1.21"

>>>>>>> 1ead78e (perubahan drastis)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
<<<<<<< HEAD
=======

>>>>>>> 1ead78e (perubahan drastis)
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

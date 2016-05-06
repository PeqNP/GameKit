import unittest

from ugf.android.gradle import GradleConfigBuilder

class GradleConfigBuilderTest (unittest.TestCase):
    def setUp(self):
        pass

    def test_build(self):
        subject = GradleConfigBuilder(tab_space=4)
        subject.insert(4, "apply plugin: 'com.android.application'")
        subject.add("allprojects", "repositories", "jcenter()")
        subject.add("dependencies", "compile fileTree(include: ['*.jar'], dir: 'libs')")
        subject.add("dependencies", "testCompile 'junit:junit:4.12'")
        subject.add("dependencies", "compile project(':adcolony')")
        subject.add("dependencies", "compile project(':adcolony')")
        subject.add("dependencies", "compile('com.twitter.sdk.android:twitter:1.3.2@aar')", "transitive = true;")
        subject.insert(0, "buildscript", "repositories", "maven { url 'https://maven.fabric.io/public' }")
        subject.insert(0, "buildscript", "dependencies", "classpath 'io.fabric.tools:gradle:1.+'")

        expected = """buildscript {
    repositories {
        maven { url 'https://maven.fabric.io/public' }
    }
    dependencies {
        classpath 'io.fabric.tools:gradle:1.+'
    }
}

apply plugin: 'com.android.application'

allprojects {
    repositories {
        jcenter()
    }
}

dependencies {
    compile fileTree(include: ['*.jar'], dir: 'libs')
    testCompile 'junit:junit:4.12'
    compile project(':adcolony')
    compile('com.twitter.sdk.android:twitter:1.3.2@aar') {
        transitive = true;
    }
}"""
        source = subject.generate()
        self.assertEqual(expected, source)

    def test_load(self):
        source = """// Top-level build file where you can add configuration options common to all sub-projects/modules.

buildscript {
    repositories {
        maven { url 'https://maven.fabric.io/public' }
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:1.5.0'

        // NOTE: Do not place your application dependencies here; they belong
        // in the individual module build.gradle files
    }
}

allprojects {
    repositories {
        jcenter()
    }
}

task clean(type: Delete) {
    delete rootProject.buildDir
}"""
        subject = GradleConfigBuilder(tab_space=4, source=source)
        subject.add("allprojects", "repositories", "mavenCentral()")
        subject.add("allprojects", "repositories", "upstartCentral()")
        
        expected = """buildscript {
    repositories {
        maven { url 'https://maven.fabric.io/public' }
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:1.5.0'
    }
}

allprojects {
    repositories {
        jcenter()
        mavenCentral()
        upstartCentral()
    }
}

task clean(type: Delete) {
    delete rootProject.buildDir
}"""
        source = subject.generate()
        self.assertEqual(expected, source)
        

if __name__ == "__main__":
    unittest.main()

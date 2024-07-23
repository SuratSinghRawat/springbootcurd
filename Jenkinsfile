pipeline
{
    agent none
    // tools{
    //    maven 'maven'
    // }
    stages{
        stage("checkout from git and stash"){
            agent any
            steps{
                git branch: 'main', url: 'https://github.com/SuratSinghRawat/springbootcurd.git'
                bat 'dir'
                stash(name: 'test', includes: '*', allowEmpty: true)
            }
        }
        stage("Unstash and Packaging build"){
            agent{ label 'jenkins-agent-sonar'}
            steps{
                unstash(name:'test')
                sh 'ls'
                // script{
                //     withSonarQubeEnv(credentialsId: 'Sonar-Jenkins')
                //     {
                //          sh 'mvn clean package sonar:sonar'
                //      }
                // }
            }
        }
        
        // stage("Code Smell "){
        //     agent {label 'sonar'}
        //     steps{
        //         script{
        //           timeout(time: 2, unit: 'MINUTES' /* 'HOURS' */) {
        //             waitForQualityGate abortPipeline: true, credentialsId: 'Sonar-Jenkins'
        //           }
        //         }
        //     }
        // }
    }
}
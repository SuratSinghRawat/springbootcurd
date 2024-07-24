pipeline
{
    agent none;
    // tools{
    //    maven 'maven'
    // }
    stages{
        stage("checkout from git and stash"){
            agent any
            steps{
                git branch: 'main', url: 'https://github.com/SuratSinghRawat/springbootcurd.git'
                bat 'dir'
                dir('../Springboot_Project')
                {
                    stash(name: 'test', includes: '*', allowEmpty: true)
                }
            }
        }
        stage("Unstash and Packaging build"){
            // tools{
            //     maven 'maven'
            // }
            agent{ label 'jenkins-agent-sonar'}
            steps{
                unstash(name: 'test')
                sh 'ls'
                script{
                    withSonarQubeEnv(credentialsId: 'sonar-token')
                    {
                         sh 'mvn clean package sonar:sonar'
                         sh sleep 30                         
                    }
                   
                }
                timeout(time: 2, unit: 'MINUTES' /* 'HOURS' */) {
                    waitForQualityGate abortPipeline: true, credentialsId: 'sonar-token'
                } 
            }
        }        
        // stage("Code Smell Check "){
        //     agent {label 'jenkins-agent-sonar'}
        //     steps{
        //         script{
        //           timeout(time: 2, unit: 'MINUTES' /* 'HOURS' */) {
        //                 script { 
        //                     waitForQualityGate abortPipeline: true
        //                 }
        //            }
        //         } 
        //     }
        // }
    }
}
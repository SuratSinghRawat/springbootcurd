pipeline
{
    agent none;
    
    stages{
        stage("checkout from git and stash"){
            agent any
            steps{
                git branch: 'main', url: 'https://github.com/SuratSinghRawat/springbootcurd.git'                
                dir('../Springboot_Project')
                {
                    stash(name: 'test', includes: '*', allowEmpty: true)
                }
            }
        }
        stage("Unstash and Packaging build"){
           
            agent{ label 'jenkins-agent-sonar'}
            steps{
                unstash(name: 'test')
                sh 'ls'
                script{
                    withSonarQubeEnv(credentialsId: 'sonar-token')
                    {
                         sh 'mvn clean package sonar:sonar'
                         sh 'sleep 10'                         
                    }                 
                }
                sh 'ls'
                stash(name: 'nx-repo', includes: '/target/springboot_ui_cicd.jar dockerfile' , allowEmpty: true)
            }
        }        
        stage("Code Smell Check "){
            agent {label 'jenkins-agent-sonar'}
            steps{
                script{
                  timeout(time: 2, unit: 'MINUTES' /* 'HOURS' */) {
                       // waitForQualityGate abortPipeline: true, credentialsId: 'sonar-token'
                      def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                   }
                } 
            }
        }
        stage("Nexus Repo upload"){
            agent {label 'jenkins-agent-nexus'}
            steps{
                unstash(name: 'nx-repo')
                sh 'ls'
                // script{                 
                    
                // } 
            }
        }
    }
}
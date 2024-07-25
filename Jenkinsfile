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
                         sh 'sleep 25'                         
                    }                 
                }
                sh 'ls'
                dir('target/'){
                    stash(name: 'nx-repo', includes: 'springboot_ui_cicd.jar' , allowEmpty: true)
                }
                stash(name: 'nx-repo1', includes: 'dockerfile' , allowEmpty: true)

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
                unstash(name: 'nx-repo1')
                sh 'ls'
                // script{                 
                    
                // } 
            }
        }
    }
}
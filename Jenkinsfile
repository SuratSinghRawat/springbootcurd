pipeline
{
    options {
        skipDefaultCheckout true
    }
    agent none;
    environment {
        dockerImage = ''
        imageName = 'springboot_ui_cicd'
        VERSION = "${env.BUILD_ID}"
        registryCredentials = "Nexus-Cred"
        registry="34.131.68.218:8082/"
    }
    
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
        stage("Nexus server::Building Image"){
            agent {label 'jenkins-agent-nexus'}
            steps{
                unstash(name: 'nx-repo')
                unstash(name: 'nx-repo1')
                script{
                  dockerImage = docker.build imageName
                }
            }
        }
        stage("Upload Image @ Nexus Repo"){
            agent {label 'jenkins-agent-nexus'}
            // steps{		  
            //     nexusArtifactUploader artifacts: 
            //     [[artifactId: 'springbootcurd',
            //     classifier: '',
            //     file: 'springboot_ui_cicd.jar',
            //     type: 'jar'
            //     ]],
            //     credentialsId: 'Nexus-Cred',
            //     groupId: 'org.springframework.boot',
            //     nexusUrl: '34.131.68.218:8081',
            //     nexusVersion: 'nexus3',
            //     protocol: 'http',
            //     repository: 'springboot-curd',
            //     version: '0.0.1-SNAPSHOT'
            // }
            steps{
                script{
                    docker.withRegistry('http://'+registry, registryCredentials){
                    dockerImage.push("${env.BUILD_NUMBER}")                    
                }
            }
            // steps{
            //     script{
            //         //dockerImage = docker.build imageName
            //       withCredentials([string(credentialsId: 'nexus_passwd', variable: 'nexus_repo_creds')]) {
            //            sh '''
            //            docker build -t 34.131.68.218:8082/springapp:${VERSION} .
            //            docker login -u admin -p nexus 34.131.68.218:8082
            //            docker push 34.131.68.218:8082/springapp:${VERSION}
            //            docker rmi 34.131.68.218:8082/springapp:${VERSION}
            //            '''
            //         }
            //     }
            // }
        }
    }
}



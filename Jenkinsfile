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
        USERNAME = 'admin'
        registryCredentials = "Nexus-Cred"
        REGISTRYIPPORT="34.131.110.34:8082"
    }
       
    stages{
        stage("checkout from git and stash"){
            agent any
            steps{
                git branch: 'main', url: 'https://github.com/SuratSinghRawat/springbootcurd.git'                
                dir('../Springboot_Project')
                {
                    stash(name: 'test', includes: '**', allowEmpty: true)
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
                // script{
                //   dockerImage = docker.build imageName
                // }
            }
        }
        stage("Upload Image : Nexus Repo"){
            agent {label 'jenkins-agent-nexus'}
            // ############################################################################
            // this section is for push artifects(.jar) on nexus 
            
            // steps{		  
            //     // for RELEASE version    
            //     nexusArtifactUploader artifacts: [[artifactId: 'springbootcurd', classifier: '', file: 'springboot_ui_cicd.jar', type: 'jar']], credentialsId: 'Nexus-Cred', groupId: 'com.dev', nexusUrl: '34.131.110.34:8081', nexusVersion: 'nexus3', protocol: 'http', repository: 'private-maven-hosted', version: '1.0'
            //     // for SNAPSHOT version
            //     //nexusArtifactUploader artifacts: [[artifactId: 'springbootcurd', classifier: '', file: 'springboot_ui_cicd.jar', type: 'jar']], credentialsId: 'Nexus-Cred', groupId: 'com.dev', nexusUrl: '34.131.110.34:8081', nexusVersion: 'nexus3', protocol: 'http', repository: 'private-maven-hosted-snapshot', version: '0.0.1-SNAPSHOT'
            //     sh 'rm *'
            // }
            // ############################################################################
            // this section is for push docker image on nexus with IP and port
            // use these emv variables at top before stages section
            // this will create one extra image i.e dockerImage = docker.build imageName
            // environment {
            //     dockerImage = ''
            //     imageName = 'springboot_ui_cicd'
            //     VERSION = "${env.BUILD_ID}"
            //     registryCredentials = "Nexus-Cred"
            //     registry="34.131.110.34:8082/"
            // }
            // steps{
            //     script{
            //         dockerImage = docker.build imageName
            //         docker.withRegistry('http://'+registry, registryCredentials){
            //             dockerImage.push("${env.BUILD_NUMBER}")  
            //         } 
            //         sh "docker rmi $registry/$imagename:$BUILD_NUMBER"                 
            //     }
            // }
            // ############################################################################
            // this section is for push docker image on nexus with IP and port
            // use these emv variables at top before stages section
            // environment{
            //     imageName = 'springapp'
            //     VERSION = "${env.BUILD_ID}"
            //     USERNAME = 'admin'
            //     PASSWD = 'nexus'
            //     REGISTRYIPPORT ="34.131.110.34:8082"
            // }
            steps{
                script{           
                    withCredentials([string(credentialsId: 'nexus_image_test', variable: 'img_nexus_data')]) {
                       sh '''
                        docker build -t ${REGISTRYIPPORT}/${imageName}:${VERSION} .
                        docker login -u admin -p nexus ${REGISTRYIPPORT}
                        docker push ${REGISTRYIPPORT}/${imageName}:${VERSION}
                        docker rmi ${REGISTRYIPPORT}/${imageName}:${VERSION}
                        
                       '''
                    }
                }
            }            
        }
        stage("Deploy Image on K8s server"){
            agent {label 'K8s-Master'}
            steps{
                script{
                   withCredentials([string(credentialsId: 'nexus_image_test', variable: 'img_nexus_data')]) {
                        sh '''
                        docker login -u admin -p nexus ${REGISTRYIPPORT}
                        docker pull ${REGISTRYIPPORT}/${imageName}:${VERSION}
                        docker tag ${REGISTRYIPPORT}/${imageName}:${VERSION} ${imageName}
                        docker rmi ${REGISTRYIPPORT}/${imageName}:${VERSION}
                        docker run -d --name myfristapp -p 8088:8088 ${imageName}
                        '''
                    }
                    
                }
            }
        }
    }
    // post{
        // always{
        //      bcc: 'rawat.surat@gmail.com', body: 'thanks for connecting ', cc: 'rawat.surat@gmail.com', from: 'rawat.bluebell@gmail.com', replyTo: '', subject: 'Test email', to: 'rawat.surat@gmail.com'
        // }
        // this is an example of all cenario 
        // always {  
        //      echo 'This will always run'  
        //  }  
        //  success {  
        //      echo 'This will run only if successful'  
        //  }  
        //  failure {  
        //      mail bcc: '', body: "<b>Example</b><br>Project: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br> URL de build: ${env.BUILD_URL}", cc: '', charset: 'UTF-8', from: '', mimeType: 'text/html', replyTo: '', subject: "ERROR CI: Project name -> ${env.JOB_NAME}", to: "foo@foomail.com";  
        //  }  
        //  unstable {  
        //      echo 'This will run only if the run was marked as unstable'  
        //  }  
        //  changed {  
        //      echo 'This will run only if the state of the Pipeline has changed'  
        //      echo 'For example, if the Pipeline was previously failing but is now successful'  
        //  }  
    // }
}



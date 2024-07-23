pipeline{
    agent none;
    stages{
        
        stage("checkout from git and stash"){
            agent any
            steps{
                git branch: 'main', url: 'https://github.com/SuratSinghRawat/springbootcurd.git'
                bat 'dir'
                stash(name: 'test', includes: '*', allowEmpty: true)
            }
        }
        stage("unstash"){
            agent{ label 'jenkins-agent-sonar'}
            steps{
                unstash(name:'test')
                sh 'ls'
            }
                
        }
    }
}
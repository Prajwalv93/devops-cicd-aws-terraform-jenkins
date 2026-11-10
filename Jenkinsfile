pipeline{
    agent any
    tools{
        jdk 'jdk17'
        nodejs 'node23'
    }
    environment {
        SCANNER_HOME=tool 'sonar-scanner'
        APP_VERSION  = "${env.BUILD_NUMBER}"
    }
    stages {
        stage('clean workspace'){
            steps{
                cleanWs()
            }
        }
    
        stage('Checkout from Git'){
            steps{
                git branch: 'master', url: 'https://github.com/Prajwalv93/end-to-end-project.git'
            }
        }
    stage("Sonarqube Analysis "){
        steps{
            withSonarQubeEnv('sonar-server') {
                sh ''' 
                $SCANNER_HOME/bin/sonar-scanner \
                    -Dsonar.projectName=Swiggy \
                    -Dsonar.projectKey=Swiggy \
                    -Dsonar.sources=.
                '''
            }
        }
    }
    stage('Quality Gate') {
        steps {
            script {
                timeout(time: 2, unit: 'MINUTES') {
                waitForQualityGate abortPipeline: true
                }
            }
        }
    }
    stage('Install Dependencies') {
        steps {
            sh "npm install"
        }
    }
    stage('Trivy Filesystem Scan') {
        steps {
            sh "trivy fs . --exit-code 0 --severity HIGH,CRITICAL -f table -o trivy-fs-report.txt"
            archiveArtifacts artifacts: 'trivy-fs-report.txt', allowEmptyArchive: true
        }
    }
    stage("Docker Build & Push"){
        steps{
            script{
                withDockerRegistry(credentialsId: 'docker-creds', toolName: 'docker'){   
                    sh "docker build -t swiggy ."
                    sh "docker tag swiggy prajwalv9343/swiggy:${env.BUILD_NUMBER}"
                    sh "docker push prajwalv9343/swiggy:${env.BUILD_NUMBER}"
                }
            }
        }
    }
    stage("TRIVY image scan"){
        steps{
            sh "trivy image prajwalv9343/swiggy:${env.APP_VERSION} > trivy.txt" 
        }
    }
    stage('Deploy to Node 1') {
        steps {
						sh """
	               
	               docker rm -f swiggy || true
	               docker ps -q --filter publish=3000 | xargs -r docker rm -f
                 docker run -d --name swiggy -p 3000:3000 prajwalv9343/swiggy:${env.APP_VERSION}
               
               """
        }
    }
    }
    post {
        always { echo "Pipeline execution completed!" }
        failure { echo "Pipeline failed. Check logs for details." }
        success { echo "Swiggy App deployed successfully! " }
    }
}
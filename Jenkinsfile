pipeline {
    agent {
        label 'agent1'
    }
    tools {
        // TODO: find way to make custom tools
        dockerTool 'docker'
        dockerTool 'helm'
        dockerTool 'k8s'
    }
    environment  {
        // Docker
        IMG_NAME = 'weather-app'
        // TODO: Get version from file
        //* VERSION = sh(script: 'cat version.txt', returnStdout: true).trim() ?: '1.0.0'
        VERSION = "${BUILD_NUMBER}"
        DOCKER_REGESTRY = 'joska99'
        DOCKER_PATH = './jenkins_project/py_app/'
        // Helm
        HELM_REPO = 'weather-app-chart'
        HELM_RELEASE = 'app'
        // Slack
        ERROR_MESSAGE = '#ff0000'
    }
    options {
        buildDiscarder(logRotator(numToKeepStr:'3'))
        disableConcurrentBuilds()
    }

    stages {
        stage('CI - Build docker image and Push to DockerHub') {
            when {
                branch 'main'
            }
            steps {
                script {
                    //! TRY+CATCH gets error and continues pipeline
                    try {
                        //! Using Docker from Tools
                        sh '''
                            docker build -t "$DOCKER_REGESTRY/$IMG_NAME:$VERSION" "$DOCKER_PATH"
                        '''
                    } catch (err) {
                        echo '<--------- ERROR IN BUILD TO DOCKER IMAGE --------->'
                        slackSend color: "${ERROR_MESSAGE}", message: "Error message: ${err}"
                        error "Failed to build Docker image: ${err}"
                    }
                }
                script {
                    withCredentials([
                        usernamePassword(
                            credentialsId: 'dockerhub-cred',
                            usernameVariable: 'USER',
                            passwordVariable: 'PSWD'
                        )
                    ]) {
                        try {
                            sh '''
                                echo "$PSWD" | sudo docker login --username "$USER" --password-stdin
                                sudo docker push "$DOCKER_REGESTRY/$IMG_NAME:$VERSION"
                            '''
                        } catch(err) {
                            echo '<--------- ERROR IN PUSH TO DOCKER HUB --------->'
                            slackSend color: "${ERROR_MESSAGE}", message: "Error message: ${err}"
                            error "Failed to push Docker image: ${err}"
                        }
                    }
                }
                // TODO: add pull request to main
                // post { success { }}
            }
        }
        // TODO: Hotfix branch
        // stage('HOTFIX_CI - Build docker image and Push to DockerHub') {
        //     when {branch 'hotfix'}
        //     steps {script {}}
        // }
        stage('CD - Helm deploy') {
            when {
                branch 'main'
            }
            steps {
                script {
                    withCredentials([
                        file(
                            credentialsId: 'kubeconfig', 
                            variable: 'KUBECONFIG'
                        )
                    ]) {
                        try {
                            //! Using Helm from DockerTols (find custom tools)
                            sh '''
                                helm upgrade $HELM_RELEASE $DOCKER_REGESTRY/$HELM_REPO \
                                    --kubeconfig $KUBECONFIG \
                                    --install \
                                    --atomic \
                                    --set value.deployment.image="$DOCKER_REGESTRY/$IMG_NAME:$VERSION"
                            '''
                        } catch(err) {
                            echo '<--------- ERROR DEPLOY HELM CHART --------->'
                            slackSend color: "${ERROR_MESSAGE}", message: "Error message: ${err}"
                            error "Failed to deploy Helm chart: ${err}"
                        }
                    }
                }
            }
        }
    }
}

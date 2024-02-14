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
        //! Get version from file
        VERSION = sh(script: 'cat version.txt', returnStdout: true).trim()
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
                branch 'dev'
            }
            steps {
                script {
                    //! Increment version from local file
                    versionArray = VERSION.tokenize('.')
                    major = versionArray[0] as int
                    minor = versionArray[1] as int
                    patch = versionArray[2] as int
                    minor++
                    env.NEW_VERSION = "$major.$minor.$patch"
                    //! Write updated version to file
                    sh "echo $NEW_VERSION > version.txt"
                }
                script {
                    //! TRY+CATCH gets error and continues pipeline
                    try {
                        //! Using Docker from Tools
                        sh '''
                            docker build -t "$DOCKER_REGESTRY/$IMG_NAME:$NEW_VERSION" "$DOCKER_PATH"
                        '''
                    } catch (err) {
                        echo '<--------- ERROR IN BUILD TO DOCKER IMAGE --------->'
                        slackSend color: "${ERROR_MESSAGE}", message: "Error message: ${err}"
                        error "Failed to build Docker image: ${err.getMessage()}"
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
                                sudo docker push "$DOCKER_REGESTRY/$IMG_NAME:$NEW_VERSION"
                            '''
                        } catch(err) {
                            echo '<--------- ERROR IN PUSH TO DOCKER HUB --------->'
                            slackSend color: "${ERROR_MESSAGE}", message: "Error message: ${err}"
                            error "Failed to push Docker image: ${err.getMessage()}"
                        }
                    }
                }
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
                                helm upgrade $HELM_RELEASE oci://docker.io/$DOCKER_REGESTRY/$HELM_REPO \
                                    --kubeconfig $KUBECONFIG \
                                    --install \
                                    --atomic \
                                    --set value.deployment.container_image="$DOCKER_REGESTRY/$IMG_NAME:$VERSION"
                            '''
                        } catch(err) {
                            echo '<--------- ERROR DEPLOY HELM CHART --------->'
                            slackSend color: "${ERROR_MESSAGE}", message: "Error message: ${err}"
                            error "Failed to deploy Helm chart: ${err.getMessage()}"
                        }
                    }
                }
            }
        }
    }
}

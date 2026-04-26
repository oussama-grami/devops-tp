pipeline {
    agent any

    tools {
        nodejs 'NodeJS-20'
    }

    environment {
        SONAR_PROJECT_KEY  = 'devops-tp'
        SCANNER_HOME       = tool 'SonarScanner'
        DOCKER_IMAGE       = 'oussemaguerami/devops-tp'
        DOCKER_TAG         = "${BUILD_NUMBER}"
        SONAR_TOKEN        = credentials('sonarqube-token')
        KUBECONFIG         = '/var/jenkins_home/.kube/config'
    }

    stages {

        stage('Checkout') {
            steps {
                echo '=== Récupération du code source ==='
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                echo '=== Installation des dépendances ==='
                sh 'npm install'
            }
        }

        stage('Unit Tests') {
            steps {
                echo '=== Exécution des tests unitaires ==='
                sh 'npm test'
            }
        }

        stage('Static Analysis - SonarQube') {
            steps {
                echo '=== Analyse SonarQube ==='
                withSonarQubeEnv('SonarQube') {
                    sh """
                        ${SCANNER_HOME}/bin/sonar-scanner \
                          -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                          -Dsonar.sources=. \
                          -Dsonar.exclusions=node_modules/**,**/*.test.js \
                          -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info
                    """
                }
            }
        }

        stage('Quality Gate') {
            steps {
                echo '=== Vérification du Quality Gate ==='
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Docker Build') {
            steps {
                echo '=== Construction de l image Docker ==='
                sh """
                    docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                    docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
                """
            }
        }

        stage('Image Scanning - Trivy') {
            steps {
                echo '=== Scan de sécurité Trivy ==='
                sh """
                    trivy image \
                      --exit-code 0 \
                      --severity HIGH,CRITICAL \
                      --format table \
                      ${DOCKER_IMAGE}:${DOCKER_TAG}
                """
            }
        }

        stage('Docker Push') {
            steps {
                echo '=== Publication sur Docker Hub ==='
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                        echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin
                        docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                        docker push ${DOCKER_IMAGE}:latest
                    """
                }
            }
        }
        stage('Load Image into Kind') {
    steps {
        echo '=== Chargement image dans kind ==='
        sh """
            kind load docker-image ${DOCKER_IMAGE}:${DOCKER_TAG} --name devops-tp
        """
    }
}

        stage('Infrastructure - Terraform') {
    steps {
        echo '=== Provisionnement Terraform ==='
        sh """
            cd terraform
            terraform init -input=false
            chmod -R 755 .terraform/
            terraform plan -out=tfplan -input=false
            terraform apply -auto-approve tfplan
        """
    }
}

        stage('Deploy - Ansible') {
            steps {
                echo '=== Déploiement Ansible ==='
                sh """
                    export DOCKER_TAG=${DOCKER_TAG}
                    export KUBECONFIG=${KUBECONFIG}
                    ansible-playbook ansible/deploy.yml
                """
            }
        }

        stage('Smoke Test') {
    steps {
        echo '=== Smoke Test ==='
        sh """
            # Lance port-forward en arrière-plan
            kubectl port-forward svc/devops-tp-service 9090:80 -n devops-tp &
            PF_PID=\$!
            
            # Attends que le port soit ouvert
            sleep 10
            
            # Test
            echo "Testing: http://localhost:9090/health"
            STATUS=\$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 http://localhost:9090/health)
            echo "HTTP Status: \$STATUS"
            
            # Arrête le port-forward
            kill \$PF_PID || true
            
            if [ "\$STATUS" != "200" ]; then
                echo "Smoke test FAILED"
                exit 1
            fi
            echo "Smoke test PASSED"
        """
    }
}
    }

    post {
        success {
            echo ' Pipeline complet terminé avec succès !'
        }
        failure {
            echo 'Pipeline échoué'
        }
        always {
            sh 'docker logout || true'
        }
    }
}

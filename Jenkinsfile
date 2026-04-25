pipeline {
    agent any

    tools {
        nodejs 'NodeJS-20'
    }

    environment {
        SONAR_PROJECT_KEY = 'devops-tp'
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
            post {
                always {
                    junit allowEmptyResults: true, testResults: '**/junit.xml'
                }
            }
        }

        stage('Static Analysis - SonarQube') {
            steps {
                echo '=== Analyse SonarQube ==='
                withSonarQubeEnv('SonarQube') {
                    sh '''
                        ${SONAR_SCANNER_HOME}/bin/sonar-scanner \
                          -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                          -Dsonar.sources=. \
                          -Dsonar.exclusions=node_modules/**,**/*.test.js \
                          -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info
                    '''
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

    }

    post {
        success {
            echo '✅ Pipeline Exercice 1 terminé avec succès !'
        }
        failure {
            echo '❌ Pipeline échoué - vérifier les logs'
        }
    }
}


pipeline {
    agent any
    stages {
        stage('拉取代码') {
            steps {
                echo "从 Git 仓库拉取最新代码..."
            }
        }
        stage('构建镜像') {
            steps {
                echo "docker build -t ops-monitor ."
            }
        }
        stage('部署上线') {
            steps {
                echo "docker compose up -d"
            }
        }
    }
}

pipeline {
  agent any
  stages {
    stage('Build docker image') {
      steps {
        sh 'docker build . -t cd_demo'
        
      }
    }

    stage('Deploy to stage') {
      steps {
        sh 'docker tag cd_demo 956684297917.dkr.ecr.us-east-1.amazonaws.com/cd_demo_stage:latest'
        sh 'docker push 956684297917.dkr.ecr.us-east-1.amazonaws.com/cd_demo_stage:latest'
        sh '''aws ecs update-service --cluster cd_demo --service cd_demo_stage --force-new-deployment

'''
      }
    }
    stage('run smoke_test') {
     steps {
      sh './tests/smoke_ecs_test'
   }
}
    stage('deploy to prod') {
      steps {
        input 'Should i deploy to Prod?'
        sh 'docker tag cd_demo 956684297917.dkr.ecr.us-east-1.amazonaws.com/cd_demo:latest'
        sh 'docker push 956684297917.dkr.ecr.us-east-1.amazonaws.com/cd_demo:latest'
        sh '''aws ecs update-service --cluster cd_demo --service cd_demo --force-new-deployment

'''
      }
    }

  }
}

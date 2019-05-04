  pipeline {
  agent {
    label "jenkins-python"
  }
  environment {
    ORG = 'invhariharan77'
    APP_NAME = 'myapp'
    CHARTMUSEUM_CREDS = credentials('jenkins-x-chartmuseum')
    VERSION = '0.0.1'
  }
  stages {
    stage ("Sleep") {
      steps {
        echo 'First of the parallel stages without further nesting'
        sleep 3 
      }
    }

    stage('Build') {
      steps {
        // Build an image for scanning
        sh 'echo "FROM ubuntu:14.04" > Dockerfile'
        sh 'echo "MAINTAINER Aqsa Fatima <aqsa@twistlock.com>" >> Dockerfile'
        sh 'echo "RUN mkdir -p /tmp/test/dir" >> Dockerfile'
        sh 'docker build --no-cache -t registry.eu-de.bluemix.net/invhariharan77/myapp:0.0.1 .'
      }
      sleep 60
   }

  stage('Scan') {
    steps {
      script {
        twistlockScan ca: '',
          cert: '',
          compliancePolicy: 'critical',
          dockerAddress: 'unix:///var/run/docker.sock',
          gracePeriodDays: 0,
          ignoreImageBuildTime: true,
          image: 'registry.eu-de.bluemix.net/invhariharan77/myapp:0.0.1',
          key: '',
          logLevel: 'true',
          policy: 'warn',
          requirePackageUpdate: false,
          timeout: 10
        }
      }
    }

  stage('Publish') {
    steps {
      script {
       twistlockPublish ca: '',
          cert: '',
          dockerAddress: 'unix:///var/run/docker.sock',
          ignoreImageBuildTime: true,
          image: 'registry.eu-de.bluemix.net/invhariharan77/myapp:0.0.1',
          key: '',
          logLevel: 'true',
          timeout: 10
      }
    }
  }

  }
  
  post {
        always {
          cleanWs()
        }
  }
}

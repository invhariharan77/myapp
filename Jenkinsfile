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
        // sh 'echo "FROM openjdk:8u151-jre-alpine" > Dockerfile'
        // sh 'echo "MAINTAINER Aqsa Fatima <aqsa@twistlock.com>" >> Dockerfile'
        // sh 'echo "RUN mkdir -p /tmp/test/dir" >> Dockerfile'
        // sh 'docker build --no-cache -t registry.eu-de.bluemix.net/invhariharan77/myapp:0.0.1 .'
        container('python') {
          // sh "git checkout master"
          sh "git clone https://github.com/invhariharan77/hellonode.git"
          sh "echo 0.0.1 > VERSION"
          // sh "python -m unittest"
          sh "docker build --no-cache -t invhariharan/hellonode:latest ."
          // sh "export VERSION=`cat VERSION` && skaffold build -f skaffold.yaml"
          // sh "jx step post build --image invhariharan/hellonode:latest"
        }
      }     
   }

  stage('Scan') {
    steps {
      sleep 5
      script {
        twistlockScan ca: '',
          cert: '',
          compliancePolicy: 'warn',
          dockerAddress: 'tcp://localhost:2375',
          gracePeriodDays: 0,
          ignoreImageBuildTime: true,
          image: 'invhariharan/hellonode:latest',
          key: '',
          logLevel: 'true',
          policy: 'warn',
          requirePackageUpdate: false,
          timeout: 10
        }
       sleep 5
      }
    }

  stage('Publish') {
    steps {
      script {
       twistlockPublish ca: '',
          cert: '',
          dockerAddress: 'tcp://localhost:2375',
          ignoreImageBuildTime: true,
          image: 'invhariharan/hellonode:latest',
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

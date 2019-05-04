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
      stage ("Prepare") {
        steps {
          echo 'First of the parallel stages without further nesting'
          sleep 3 
        }
      }

      stage('Build') {
        when {
          branch 'master'
        }
        steps {
          container('python') {
            // ensure we're not on a detached head
            sh "git checkout master"
            sh "git config --global credential.helper store"
            sh "jx step git credentials"

            // so we can retrieve the version in later steps
            sh "echo \$(jx-release-version) > VERSION"
            sh "jx step tag --version \$(cat VERSION)"
            sh "python -m unittest"
            sh "export VERSION=`cat VERSION` && skaffold build -f skaffold.yaml"
          }
        }
      }
      
      stage('Scan') {
        steps {
          sleep 5
          script {
            twistlockScan ca: '',
              cert: '',
              compliancePolicy: 'low',
              dockerAddress: 'tcp://localhost:2375',
              gracePeriodDays: 0,
              ignoreImageBuildTime: true,
              image: 'registry.eu-de.bluemix.net/invhariharan77/myapp:0.0.1',
              key: '',
              logLevel: 'true',
              policy: 'low',
              requirePackageUpdate: false,
              timeout: 10,
              containerized: 'true'
          }
          sleep 5
        }
      }

      stage('Report') {
        steps {
          script {
           twistlockPublish ca: '',
              cert: '',
              dockerAddress: 'tcp://localhost:2375',
              ignoreImageBuildTime: true,
              image: 'registry.eu-de.bluemix.net/invhariharan77/myapp:0.0.1',
              key: '',
              logLevel: 'true',
              timeout: 10,
              containerized: 'true'
          }
          sleep 50000
        }
      }
    }
    
    stage('Publish') {
      steps {
        container('python') {
          sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:\$(cat VERSION)"
        }
      }
    }

    post {
      always {
        cleanWs()
      }
    }
}

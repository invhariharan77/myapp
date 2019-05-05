  pipeline {
    agent {
      label "jenkins-python"
    }
    environment {
      DOCKER_REGISTRY = 'registry.eu-de.bluemix.net'
      ORG = 'invhariharan77'
      APP_NAME = 'myapp'
      CHARTMUSEUM_CREDS = credentials('jenkins-x-chartmuseum')
      VERSION = '0.0.30'
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
            sh "docker tag registry.eu-de.bluemix.net/invhariharan77/myapp:0.0.30 scan-registry.eu-de.bluemix.net/invhariharan77/myapp:0.0.30"
          }
        }
      }
      
      stage('Scan') {
        steps {
          sleep 5
          script {
            twistlockScan ca: '',
              cert: '',
              compliancePolicy: 'critical',
              dockerAddress: 'tcp://localhost:2375',
              gracePeriodDays: 0,
              ignoreImageBuildTime: true,
              image: 'scan-registry.eu-de.bluemix.net/invhariharan77/myapp:0.0.30',
              key: '',
              logLevel: 'true',
              policy: 'warn',
              requirePackageUpdate: false,
              timeout: 10
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
              image: 'scan-registry.eu-de.bluemix.net/invhariharan77/myapp:0.0.30',
              key: '',
              logLevel: 'true',
              timeout: 10
          }
          sleep 5
        }
      }
         
      stage('Publish') {
        steps {
          container('python') {
            sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:\$(cat VERSION)"
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

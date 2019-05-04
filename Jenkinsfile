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
    stage('CI Build and push snapshot') {
      when {
        branch 'PR-*'
      }
      environment {
        PREVIEW_VERSION = "0.0.0-SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
        PREVIEW_NAMESPACE = "$APP_NAME-$BRANCH_NAME".toLowerCase()
        HELM_RELEASE = "$PREVIEW_NAMESPACE".toLowerCase()
      }
      steps {
        container('python') {
          sh "python -m unittest"
          sh "export VERSION=$PREVIEW_VERSION && skaffold build -f skaffold.yaml"
          sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:$PREVIEW_VERSION"
          dir('./charts/preview') {
            sh "make preview"
            sh "jx preview --app $APP_NAME --dir ../.."
          }
        }
      }
    }
    stage('Build Release') {
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
          // sh "echo \$(jx-release-version) > VERSION"
          sh "echo 0.0.1 > VERSION"
          // sh "jx step tag --version \$(cat VERSION)"
          sh "python -m unittest"
          sh "export VERSION=`cat VERSION` && skaffold build -f skaffold.yaml"
          sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:\$(cat VERSION)"
        }
      }
    }
 
    stage('Scan with Twistlock') {
        steps {
            echo "About to invoke twistlock scan"
            echo "Image: $DOCKER_REGISTRY/$ORG/$APP_NAME:$VERSION"
            sleep 3
            script {
                twistlockScan ca: '', cert: '', compliancePolicy: 'warn', \
                  containerized: true, dockerAddress: 'unix:///var/run/docker.sock', \
                  gracePeriodDays: 0, ignoreImageBuildTime: false, \
                  image: '$DOCKER_REGISTRY/$ORG/$APP_NAME:$VERSION', key: '', \
                  logLevel: 'true', policy: 'warn', requirePackageUpdate: false, timeout: 60
            }
            echo "done"
            sleep 300
        }
    }
  
    stage('Publish to Twistlock') {
        steps {
            echo "About to invoke twistlock publish"
            echo "Image: $DOCKER_REGISTRY/$ORG/$APP_NAME:$VERSION"
            sleep 3
            script {
                twistlockPublish ca: '', cert: '',  containerized: true, \
                    dockerAddress: 'unix:///var/run/docker.sock', key: '', \
                    image: '$DOCKER_REGISTRY/$ORG/$APP_NAME:$VERSION', \
                    logLevel: 'true', timeout: 60
            }
            sleep 3000
            echo "done"
        }
    }  
  }
  
  post {
        always {
          cleanWs()
        }
  }
}

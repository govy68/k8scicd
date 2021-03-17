podTemplate(label: 'jenkins-slave-pod', 
  containers: [
    containerTemplate(name: 'build',   image: 'golang', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'test',     image: 'golang', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'docker', image: 'docker', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'run',     image: 'golang', ttyEnabled: true, command: 'cat')
  ],
  volumes: [ 
    hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'), 
  ]
)


{
    node('jenkins-slave-pod') { 

        def registry = "10.101.240.188.129:5000"
        def imagename = "k8scicd"
        def registryCredential = "private-repository-id"

        stage('build~~~~') {
            container('build') {
                // Create our project directory.
                sh 'cd ${GOPATH}/src'
                sh 'mkdir -p ${GOPATH}/src/hello-world'
                // Copy all files in our Jenkins workspace to our project directory.                
                sh 'cp -r ${WORKSPACE}/* ${GOPATH}/src/hello-world'
                // Build the app.
                sh 'go build'  

            }
        }

        stage('Test~~~~') {
            container('test') {
                 // Create our project directory.
                sh 'cd ${GOPATH}/src'
                sh 'mkdir -p ${GOPATH}/src/hello-world'
                // Copy all files in our Jenkins workspace to our project directory.
                sh 'cp -r ${WORKSPACE}/* ${GOPATH}/src/hello-world'
                // Remove cached test results.
                sh 'go clean -cache'
                // Run Unit Tests.
                sh 'go test ./... -v -short'
            }
        }

        stage('Build docker image') {
            container('docker') {
                withDockerRegistry([ credentialsId: "$registryCredential", url: "http://$registry" ]) {
                    sh "docker build -t $registry/$imagename:$BUILD_NUMBER -f ./Dockerfile ."
                }
            }
        }

        stage('Push docker image') {
            container('docker') {
                withDockerRegistry([ credentialsId: "$registryCredential", url: "http://$registry" ]) {
                    docker.image("$registry/$imagename:$BUILD_NUMBER").push()
                }
            }
        }

        stage('Deploy~~~~~~~~~~') {
            container('run') {
                    def image_id = $registry/$imagename + ":$BUILD_NUMBER"
                    sh "ansible-playbook  playbook.yml --extra-vars \"image_id=${image_id}\""
            }
        }
    }
}

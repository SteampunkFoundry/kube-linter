def label = "ImageBuildPod-${UUID.randomUUID().toString()}"

properties([
  parameters([
    string(name: 'kube_linter_version', defaultValue: '0.2.0')
  ])
])

podTemplate(
  label: label,
  containers: [
    containerTemplate(name: 'docker',
                      image: 'docker:20.10.6',
                      ttyEnabled: true,
                      command: 'cat',
                      envVars: [containerEnvVar(key: 'DOCKER_HOST', value: "unix:///var/run/docker.sock")],
                      privileged: true),
    containerTemplate(name: 'checkov', image: 'bridgecrew/checkov', ttyEnabled: true, command: 'cat')
  ],
  volumes: [hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock')],
  nodeSelector: 'role=infra'
) {
  node(label) {
    container('docker') {
      def image

      stage('Checkout Code') {
        cleanWs()
        checkout scm
      }

      stage('Container') {
        container('checkov') {
          stage('Checkov Analysis') {
            ansiColor('xterm') {
              sh('checkov --directory . -o cli || true')
              sh('checkov --directory . -o junitxml > result.xml')
              junit 'result.xml'
            }
          }
        }
      }

      stage('Build'){
        ansiColor('xterm') {
          // Since the Dockerfile needs network connectivity, connect to the k8s sidecar with --network: https://stackoverflow.com/a/49408621/64217
          image = docker.build("steampunkfoundry/kube-linter:${env.BUILD_ID}", "--network container:\$(docker ps | grep \$(hostname) | grep k8s_POD | cut -d\" \" -f1) --build-arg kube_linter_version=${params.kube_linter_version} .")
          image.tag("latest")
          image.tag("v${params.kube_linter_version}")
        }
      }

      stage('Push'){
        docker.withRegistry("https://registry.hub.docker.com", "ggotimer-docker-hub") {
          image.push("latest")
          image.tag("v${params.kube_linter_version}")
        }
      }
    }
  }
}

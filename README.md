# kube-linter

A new Docker image for [StackRox KubeLinter](https://github.com/stackrox/kube-linter)
that can be used in a Jenkins pipeline.

## Using

From a command line:

```bash
docker run -v ${PWD}:/src ggotimer/kube-linter /kube-linter lint /src
```

In `Jenkinsfile`:

```Jenkinsfile
containerTemplate(name: 'kubelinter', image: 'ggotimer/kube-linter', ttyEnabled: true, command: 'cat')
...
stage('Container') {
    container('kubelinter') {
        stage('KubeLinter Analysis') {
            ansiColor('xterm') {
                sh('/kube-linter lint . || true')
            }
        }
    }
}
```

## Building

```bash
docker build -t ggotimer/kube-linter .
```

## Rationale

The [existing image](https://hub.docker.com/r/stackrox/kube-linter) is based on
a `scratch` image and contains nothing more than the `kube-linter` binary.

It cannot be used as container in our normal pipeline since it isn't long
running. Normally, we'd just use the `cat` command, but since it is based on
`scratch`, there are no shells or commands to run. Therefore we'd use the
`docker` image (i.e., Docker-in-Docker) to run it. But when you mount the local
directory to be scanned to the inner Docker container, it mounts the directory
from the host, not the Jenkins agent pod. The repository to be scanned is not on
the host, but on the Jenkins agent pod.

Rather that recreate directories or copy files around, we thought it would be
easier to make a new KubeLinter image based on another base image that can stay
long running. It felt less kludgey.

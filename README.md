# Jenkins X Builders for AI team

A Jenkins X builder allows to build a Docker image that can be used as a container in a Jenkins X 
[Pod Templates](https://jenkins-x.io/docs/reference/components/pod-templates/).

The Kubernetes plugin uses pod templates to define the pod used to run a CI/CD pipeline which consists of:

- one or more build containers for running commands inside (build tools like `mvn` or `npm` along with pipeline tools 
like `git`, `jx`, `helm`, `kubectl` etc)
- volumes for persistence
- environment variables
- secrets

See the default [Jenkins X builders](https://github.com/jenkins-x/jenkins-x-builders).

## Dependency Matrix

Upstream versions can be retrieved from the dependency matrix files. See [Jenkins X Platform dependency matrix](https://github.com/jenkins-x/jenkins-x-platform/blob/master/dependency-matrix/matrix.yaml)
that correlates:  
jenkins-x-platform v2.0.1849 with jenkins-x-builders v2.0.1117-453

### Resources

- https://github.com/jenkins-x/jenkins-x-builders
- https://github.com/jenkins-x/jenkins-x-platform
- https://github.com/jenkins-x/jenkins-x-builders-base
- https://github.com/jenkins-x/jenkins-x-builders-base-image

## Image Builds

### Pull Request

The deployed versions are `$NEXT_VERSION-$BRANCH_NAME`.

For instance, to test the `builder-maven-nodejs` builder, you can refer to the next version image produced from the 
pull request, for instance:

```bash
docker-registry.ai.dev.nuxeo.com/nuxeo/builder-maven-nodejs:0.0.2-PR-1
```

### master

The deployed versions are `x.y.z` (depending on the Git tag) or `latest`.

## Notes

All builders are versioned with the same version.

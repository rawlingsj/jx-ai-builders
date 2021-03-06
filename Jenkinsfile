/*
 * (C) Copyright 2020 Nuxeo (http://nuxeo.com/) and others.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Contributors:
 *     Julien Carsique <jcarsique@nuxeo.com>
 */

void setGitHubBuildStatus(String context) {
    if (NAMESPACE == 'ai-staging') { // No GitHub status from ai-staging
        return
    }
    step([
            $class       : 'GitHubCommitStatusSetter',
            reposSource  : [$class: 'ManuallyEnteredRepositorySource', url: 'https://github.com/nuxeo/jx-ai-builders'],
            contextSource: [$class: 'ManuallyEnteredCommitContextSource', context: context],
            errorHandlers: [[$class: 'ShallowAnyErrorHandler']]
    ])
}

void setGitHubBuildStatus(String context, String message, String state) {
    step([$class            : 'GitHubCommitStatusSetter',
          reposSource       : [$class: 'ManuallyEnteredRepositorySource', url: "https://github.com/nuxeo/jx-ai-builders"],
          contextSource     : [$class: 'ManuallyEnteredCommitContextSource', context: context],
          statusResultSource: [$class: 'ConditionalStatusResultSource', results: [[$class: 'AnyBuildResult', message: message, state: state]]],
    ])
}

void skaffoldGen() {
    withEnv(["VERSION=${VERSION}"]) {
        sh '''
envsubst < skaffold.yaml > skaffold.yaml~gen

# dry-run requires skaffold 1.9+
#skaffold build -f skaffold.yaml~gen -q --dry-run
'''
    }
}

void skaffoldBuild(String buildImage) {
    withEnv(["VERSION=${VERSION}"]) {
        echo "Build ${DOCKER_REGISTRY}/${ORG}/${buildImage}:${VERSION}"
        sh """
skaffold build -f skaffold.yaml~gen -b $buildImage
"""
    }
}

def skaffoldBuildStage(String buildImage) {
    return {
        stage("$buildImage") {
            try {
                setGitHubBuildStatus("build/$buildImage")
                container('jx-base') {
                    timeout(activity: true, time: 120) {
                        skaffoldBuild("$buildImage")
                    }
                }
                currentBuild.setResult('SUCCESS')
            } catch(Throwable t) {
                currentBuild.setResult('FAILURE')
                throw t
            } finally {
                setGitHubBuildStatus("build/$buildImage")
            }
        }
    }
}

pipeline {
    agent {
        kubernetes {
            label 'jenkins-jx-base'
            yaml """
spec:
  containers:
  - name: "jx-base"
    resources:
      limits:
        memory: "16Gi"
        cpu: "8"
      requests:
        memory: "4Gi"
        cpu: "2"
"""
        }
    }
    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(daysToKeepStr: '60', numToKeepStr: '20', artifactNumToKeepStr: '1'))
        timeout(time: 5, unit: 'HOURS')
    }
    environment {
        ORG = 'nuxeo'
        INTERNAL_DOCKER_REGISTRY = 'docker-registry.ai.dev.nuxeo.com'
        NAMESPACE = ''
        VERSION = ''
        SCM_REF = "${sh(script: 'git show -s --pretty=format:\'%h%d\'', returnStdout: true).trim();}"
    }
    stages {
        stage('Init') {
            steps {
                container('jx-base') {
                    sh '''#!/bin/bash -xe
jx step git credentials
git config credential.helper store
'''
                    script {
                        NAMESPACE = sh(script: "jx -b ns | cut -d\\' -f2", returnStdout: true).trim()
                        String releaseVersion = sh(returnStdout: true, script: 'jx-release-version')
                        VERSION = BRANCH_NAME == 'master' ? releaseVersion : releaseVersion + "-${BRANCH_NAME}"
                    }
                    skaffoldGen()
                }
            }
        }
        stage('Build') {
            steps {
                script {
                    skaffoldBuildStage("builder-base").call()
                    stage('Custom Builders') {
                        def builders = ['builder-java8', 'builder-java11',
                                        'builder-nodejs',
                                        'builder-nuxeo1010',
                                        'builder-python36', 'builder-python37']
                        parallel(builders.collectEntries {
                            [("${it}".toString()): skaffoldBuildStage(it)]
                        })
                    }
                }
            }
        }
        stage('Release') {
            when {
                branch 'master'
                expression { NAMESPACE == 'ai' }
            }
            steps {
                setGitHubBuildStatus('release')
                container('jx-base') {
                    echo "Releasing version ${VERSION}"
                    sh """#!/bin/bash -xe
jx step tag -v ${VERSION}
jx step changelog -v v${VERSION}

# update builders version in the other repositories
./updatebot.sh ${VERSION}
"""
                }
            }
            post {
                always {
                    setGitHubBuildStatus('release')
                    step([$class: 'JiraIssueUpdater', issueSelector: [$class: 'DefaultIssueSelector'], scm: scm])
                }
            }
        }
    }
}

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

void setGitHubBuildStatus(String context, String message, String state) {
    if (NAMESPACE == 'ai-staging') { // No GitHub status from ai-staging
        return
    }
    step([$class            : 'GitHubCommitStatusSetter',
          reposSource       : [$class: 'ManuallyEnteredRepositorySource', url: 'https://github.com/nuxeo/jx-ai-builders'],
          contextSource     : [$class: 'ManuallyEnteredCommitContextSource', context: context],
          statusResultSource: [$class: 'ConditionalStatusResultSource', results: [[$class: 'AnyBuildResult', message: message, state: state]]],
    ])
}

String getReleaseVersion() {
    return sh(returnStdout: true, script: 'jx-release-version')
}

String getVersion() {
    return BRANCH_NAME == 'master' ? getReleaseVersion() : getReleaseVersion() + "-$BRANCH_NAME"
}

void skaffoldGen() {
    withEnv(["VERSION=${getVersion()}"]) {
        sh '''
export SCM_REF=$(git show -s --pretty=format:'%h%d' 2>/dev/null ||echo unknown)
envsubst < skaffold.yaml > skaffold.yaml~gen

# dry-run requires skaffold 1.9+
#skaffold build -f skaffold.yaml~gen -q --dry-run
'''
    }
}

void skaffoldBuild(String buildImage) {
    withEnv(["VERSION=${getVersion()}"]) {
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
                setGitHubBuildStatus("build/$buildImage", "Build $buildImage image", 'PENDING')
                container('jx-base') {
                    skaffoldBuild("$buildImage")
                }
                setGitHubBuildStatus("build/$buildImage", "Build $buildImage image", 'SUCCESS')
            } catch (Throwable cause) {
                setGitHubBuildStatus("build/$buildImage", "Build $buildImage image", 'FAILURE')
                throw cause
            }
        }
    }
}

pipeline {
    agent {
        label 'jenkins-jx-base'
    }
    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(daysToKeepStr: '60', numToKeepStr: '20', artifactNumToKeepStr: '1'))
        timeout(time: 1, unit: 'HOURS')
    }
    environment {
        ORG = 'nuxeo'
        INTERNAL_DOCKER_REGISTRY = 'docker-registry.ai.dev.nuxeo.com'
        NAMESPACE = ''
    }
    stages {
        stage('Init') {
            steps {
                container('jx-base') {
                    sh '''#!/bin/bash -xe
jx step git credentials
git config credential.helper store
git fetch --tags --quiet
'''
                    script {
                        NAMESPACE = sh(script: "jx -b ns | cut -d\\' -f2", returnStdout: true).trim()
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
                container('jx-base') {
                    script {
                        setGitHubBuildStatus('release', 'Release', 'PENDING')
                        withEnv(["VERSION=${getReleaseVersion()}"]) {
                            echo "Releasing version ${VERSION}"
                            sh '''#!/bin/bash -xe
jx step tag -v ${VERSION}
jx step changelog -v v${VERSION}

# update builders version in the other repositories
./updatebot.sh ${VERSION}
'''
                        }
                    }
                }
            }
            post {
                always {
                    step([$class: 'JiraIssueUpdater', issueSelector: [$class: 'DefaultIssueSelector'], scm: scm])
                }
                success {
                    setGitHubBuildStatus('release', 'Release', 'SUCCESS')
                }
                failure {
                    setGitHubBuildStatus('release', 'Release', 'FAILURE')
                }
            }
        }
    }
}

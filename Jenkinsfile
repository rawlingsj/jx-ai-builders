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
    return BRANCH_NAME == 'master' ? 'latest' : getReleaseVersion() + BRANCH_NAME
}

void skaffoldBuild(String buildImage) {
    withEnv(["VERSION=${getVersion()}"]) {
        echo "Build image ${buildImage} version ${VERSION}"
        sh """
export SCM_REF=\$(git show -s --pretty=format:'%h%d' 2>/dev/null ||echo unknown)
envsubst < skaffold.yaml > skaffold.yaml~gen
skaffold build -f skaffold.yaml~gen -b $buildImage
"""
    }
}

def skaffoldBuildStage(String buildImage) {
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
                }
            }
        }
        stage('Build all builders') {
            steps {
                script {
                    skaffoldBuildStage("builder-base")
                    stage('Custom Builders') {
                        parallel {
                            skaffoldBuildStage('builder-base')
                            skaffoldBuildStage('builder-java8')
                            skaffoldBuildStage('builder-java11')
                            skaffoldBuildStage('builder-nodejs')
                            skaffoldBuildStage('builder-nuxeo1010')
                        }
                    }
                }
            }
        }
        stage('Release') {
            when {
                branch 'NOmaster'
            }
            steps {
                container('jx-base') {
                    script {
                        def currentNamespace = sh(returnStdout: true, script: "jx --batch-mode ns | cut -d\\' -f2").trim()
                        if (currentNamespace == 'ai-staging') {
                            echo "Running in namespace ${currentNamespace}, skip GitHub release stage."
                            return
                        }
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

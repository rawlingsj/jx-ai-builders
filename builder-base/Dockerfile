# (C) Copyright 2020 Nuxeo (http://nuxeo.com/) and others.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ARG JX_BUILDER_VERSION=2.0.1117-453
FROM gcr.io/jenkinsxio/builder-jx:${JX_BUILDER_VERSION}

ARG DESCRIPTION="Base image for the AI builds"
ARG SCM_REPOSITORY=git@github.com:nuxeo/jx-ai-builders.git
ARG VERSION=unknown
ARG SCM_REF=unknown

LABEL description=${DESCRIPTION}
LABEL scm-url=${SCM_REPOSITORY}
LABEL version=${VERSION}
LABEL scm-ref=${SCM_REF}

USER root

RUN yum -y update && \
    yum -y install epel-release deltarpm && \
    yum -y --setopt=skip_missing_names_on_install=False install \
        ghostscript \
        ImageMagick \
        libreoffice-calc libreoffice-headless libreoffice-impress libreoffice-writer \
        libwpd-tools \
        perl-Archive-Zip \
        perl-Image-ExifTool \
        poppler-utils \
        ufraw \
        sudo \
        expect && \
    yum clean all

# semver tool
RUN mkdir -p /opt/build/tools && \
    cd /opt/build/tools && \
    wget https://raw.githubusercontent.com/fsaintjacques/semver-tool/3.0.0/src/semver && \
    chmod +x semver && \
    ln -s /opt/build/tools/semver /usr/bin/semver

# Add jenkins user
# TODO: run pipelines with a non root user (NXBT-2892, NXS-5690)
#ARG JENKINS_USER=jenkins
# -M: home directory is created by the builder-base image (see jenkins-x/jenkins-x-builders-base)
#RUN groupadd -g 10000 ${JENKINS_USER} && \
#    useradd -u 10000 -g 10000 -M -s /bin/bash ${JENKINS_USER} && \
#    chown 10000:10000 /home/jenkins && \
#    chmod 755 /home/jenkins && \
#    echo "jenkins  ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/jenkins

#USER ${JENKINS_USER}

RUN echo ${DESCRIPTION}:${SCM_URL}:${SCM_REF}:${VERSION} > /home/jenkins/.ai-builder-base

CMD ["tail", "-f", "/dev/null"]

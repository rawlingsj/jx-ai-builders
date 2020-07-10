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

#ARG JX_BUILDER_VERSION=2.0.1117-453
#FROM gcr.io/jenkinsxio/builder-jx:${JX_BUILDER_VERSION}
ARG BASE_BUILDER_VERSION=0.0.80
FROM gcr.io/jenkinsxio/builder-base:${BASE_BUILDER_VERSION}

ARG VERSION
ARG SCM_REF
ARG BUILD_TAG

LABEL version=${VERSION}
LABEL scm-ref=${SCM_REF}
LABEL description="Base builder image for the AI custom builders"
LABEL scm-url=git@github.com:nuxeo/jx-ai-builders.git
LABEL build-tag=${BUILD_TAG}
LABEL maintainer="Nuxeo AI <ai-team@nuxeo.com>"

USER root

# jx
ENV JX_VERSION 2.0.1240
RUN curl -f -L https://github.com/jenkins-x/jx/releases/download/v${JX_VERSION}/jx-linux-amd64.tar.gz | tar xzv && \
  mv jx /usr/bin/

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

# reg: Docker registry v2 command line client
RUN export REG_SHA256="ade837fc5224acd8c34732bf54a94f579b47851cc6a7fd5899a98386b782e228" && \
    curl -fSL "https://github.com/genuinetools/reg/releases/download/v0.16.1/reg-linux-amd64" -o "/usr/bin/reg" && \
	echo "${REG_SHA256}  /usr/bin/reg" | sha256sum -c - && \
	chmod +x "/usr/bin/reg"

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

CMD ["tail", "-f", "/dev/null"]

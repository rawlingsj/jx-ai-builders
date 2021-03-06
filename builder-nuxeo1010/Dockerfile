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

ARG BASE_IMAGE
FROM ${BASE_IMAGE}

LABEL description="Nuxeo 10.10 environment builder for AI team"

#USER root

# Maven
ARG MAVEN_VERSION=3.6.3
RUN curl --retry 5 -fsSL https://repo1.maven.org/maven2/org/apache/maven/apache-maven/${MAVEN_VERSION}/apache-maven-${MAVEN_VERSION}-bin.tar.gz | tar -C /opt -xzv

# Java and conversion tools
ARG JDK_VERSION=1.8.0
RUN yum -y --setopt=skip_missing_names_on_install=False install \
  java-${JDK_VERSION}-openjdk java-${JDK_VERSION}-openjdk-devel \
  # tzdata-java-2020a doesn't work with java (NXBT-3325)
  && yum -y downgrade tzdata-java-2019c-1.el7 \
  && yum clean all
RUN alternatives --set java java-${JDK_VERSION}-openjdk.x86_64

# NodeJS
ARG NODEJS_VERSION=10
RUN curl --retry 5 -fsSL https://rpm.nodesource.com/setup_${NODEJS_VERSION}.x | bash - && \
  yum install -y nodejs gcc-c++ make \
  && yum clean all

ARG BOWER_VERSION=1.8.8
ARG GULP_VERSION=2.0.1
ARG GRUNT_VERSION=1.3.1
RUN npm i -g bower@${BOWER_VERSION} gulp-cli@${GULP_VERSION} grunt-cli@${GRUNT_VERSION}

# Yarn
ARG YARN_VERSION=1.19.2
RUN curl --retry 5 -fsSL -o /tmp/yarn.tgz https://github.com/yarnpkg/yarn/releases/download/v${YARN_VERSION}/yarn-v${YARN_VERSION}.tar.gz && \
	tar xf /tmp/yarn.tgz && \
	mv yarn-v${YARN_VERSION} /opt/yarn && \
	ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn

# Chromium, chromedriver, Xvfb
RUN yum install -y GConf2 gtk2 chromedriver chromium xorg-x11-server-Xvfb
RUN npm i -g vsce typescript aws-cdk

# geckodriver
ARG GECKODRIVER_VERSION=0.26.0
RUN curl --retry 5 -fsSL https://github.com/mozilla/geckodriver/releases/download/v${GECKODRIVER_VERSION}/geckodriver-v${GECKODRIVER_VERSION}-linux64.tar.gz | tar -C /usr/local/bin -xzv

#ARG JENKINS_USER=jenkins
#USER ${JENKINS_USER}

ENV M2_HOME /opt/apache-maven-${MAVEN_VERSION}
ENV maven.home ${M2_HOME}
ENV M2 ${M2_HOME}/bin
ENV PATH ${M2}:${PATH}

CMD ["tail", "-f", "/dev/null"]

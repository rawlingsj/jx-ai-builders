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

#USER root

# Maven
ARG MAVEN_VERSION=3.6.3
RUN curl -f -L https://repo1.maven.org/maven2/org/apache/maven/apache-maven/${MAVEN_VERSION}/apache-maven-${MAVEN_VERSION}-bin.tar.gz | tar -C /opt -xzv

# Java and conversion tools
ARG JDK_VERSION=1.8.0
LABEL description="Java ${JDK_VERSION} builder for AI team"
RUN yum -y --setopt=skip_missing_names_on_install=False install \
  java-${JDK_VERSION}-openjdk java-${JDK_VERSION}-openjdk-devel \
  # tzdata-java-2020a doesn't work with java (NXBT-3325)
  && yum -y downgrade tzdata-java-2019c-1.el7 \
  && yum clean all
RUN alternatives --set java java-${JDK_VERSION}-openjdk.x86_64

#ARG JENKINS_USER=jenkins
#USER ${JENKINS_USER}

ENV M2_HOME /opt/apache-maven-${MAVEN_VERSION}
ENV maven.home ${M2_HOME}
ENV M2 ${M2_HOME}/bin
ENV PATH ${M2}:${PATH}

CMD ["mvn", "--version"]

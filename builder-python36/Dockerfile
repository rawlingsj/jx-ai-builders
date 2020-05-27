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

LABEL description="Python 3.6 builder for AI team"

#USER root

# https://github.com/jenkins-x/jenkins-x-builders/blob/master/builder-python37/Dockerfile
RUN yum -y install gcc openssl-devel bzip2-devel libffi-devel libsqlite3x-devel && \
    yum clean all
ENV PYTHONVERSION 3.6.10
RUN cd /usr/src && \
    wget https://www.python.org/ftp/python/${PYTHONVERSION}/Python-${PYTHONVERSION}.tgz && \
    tar xzf Python-${PYTHONVERSION}.tgz && \
    cd Python-${PYTHONVERSION} && \
    ./configure --enable-optimizations --enable-loadable-sqlite-extensions && \
    make altinstall && \
    rm /usr/src/Python-${PYTHONVERSION}.tgz && \
    cd ../ && \
    rm -rf /usr/src/Python-${PYTHONVERSION} && \
    ln -fs /usr/local/bin/python3.6 /usr/bin/python3 && \
    yum -y remove gcc openssl-devel bzip2-devel libsqlite3x-devel && \
    yum clean all && \
    easy_install-3.6 pip && \
    pip install --upgrade pip && \
    pip install --upgrade awscli && \
    pip install --upgrade awscli-local && \
    pip install --upgrade tox && \
    pip install --upgrade pipdeptree

# https://github.com/jenkins-x/jenkins-x-builders/blob/master/builder-python/Dockerfile
#RUN yum install -y https://centos7.iuscommunity.org/ius-release.rpm && \
#    yum install -y python36u python36u-libs python36u-devel python36u-pip && yum clean all && \
#    ln -fs /usr/bin/python3.6 /usr/bin/python3

#yum -y install python36 python36-devel

#ARG JENKINS_USER=jenkins
#USER ${JENKINS_USER}

CMD ["python3", "--version"]

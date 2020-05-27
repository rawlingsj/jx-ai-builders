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

LABEL description="NodeJS builder for AI team"

#USER root

# NodeJS
ARG NODEJS_VERSION=10
RUN curl -f --silent --location https://rpm.nodesource.com/setup_${NODEJS_VERSION}.x | bash - && \
  yum install -y nodejs gcc-c++ \
  && yum clean all

#ARG JENKINS_USER=jenkins
#USER ${JENKINS_USER}

CMD ["nodejs","--version"]

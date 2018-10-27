FROM jenkinsci/blueocean
MAINTAINER Justin Menga <justin.menga@gmail.com>
LABEL application=jenkins

# Change to root user
USER root

# Used to set the docker group ID
ARG TIMEZONE=America/Los_Angeles
COPY src/build/ /build/

RUN echo "@community http://nl.alpinelinux.org/alpine/edge/community/" >> /etc/apk/repositories
RUN apk update 
RUN apk add build-base

RUN apk add --virtual build-dependencies python-dev openssl-dev libffi-dev musl-dev git tzdata libsodium-dev shadow

RUN apk add py-pip make docker@community jq su-exec

RUN cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
RUN echo "${TIMEZONE}" >  /etc/timezone
RUN  pip install --upgrade pip
RUN  pip install --no-cache-dir -r /build/requirements.txt
RUN rm -rf /build

ARG DOCKER_GID=497
RUN usermod -aG docker jenkins
# Change to jenkins user
USER jenkins

# Add Jenkins plugins
RUN /usr/local/bin/install-plugins.sh github dockerhub-notification workflow-aggregator zentimestamp swarm blueocean ansible ansicolor

# Add Jenkins init files
COPY src/jenkins/ /usr/share/jenkins/ref/

# Entrypoint
ENV DOCKER_GID=497
COPY src/entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/sbin/tini","--","/usr/local/bin/jenkins.sh"]
 
# Change to root so that we can set Docker GID on container startup
USER root
#
# most of this is copied from:
# https://github.com/hseeberger/scala-sbt
#

FROM  openjdk:8

ENV SCALA_VERSION 2.12.1
ENV SBT_VERSION 0.13.13

# create a user with uid 1000
RUN useradd -d "/home/sample" -u 1000 -m -s /bin/bash sample

# Scala expects this file
RUN touch /usr/lib/jvm/java-8-openjdk-amd64/release

# Install Scala
## Piping curl directly in tar
RUN \
  curl -fsL http://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /home/sample/ && \
  echo >> /home/sample/.bashrc && \
  echo 'export PATH=~/scala-$SCALA_VERSION/bin:$PATH' >> /home/sample/.bashrc

# Install sbt
RUN \
  curl -L -o sbt-$SBT_VERSION.deb http://dl.bintray.com/sbt/debian/sbt-$SBT_VERSION.deb && \
  dpkg -i sbt-$SBT_VERSION.deb && \
  rm sbt-$SBT_VERSION.deb && \
  apt-get update && \
  apt-get install sbt && \
  sbt sbtVersion

# now install Z3 and build apron from the sample repo
RUN apt-get install libgomp1 libgmp-dev libmpfr-dev libppl-dev openjdk-8-jdk build-essential -y

RUN mkdir -p /opt/z3 && cd /opt/z3 && wget https://github.com/Z3Prover/z3/releases/download/z3-4.5.0/z3-4.5.0-x64-debian-8.5.zip && unzip z3-4.5.0-x64-debian-8.5.zip && ln -s `pwd`/z3-4.5.0-x64-debian-8.5/bin/z3 /usr/bin/z3
# build apron from sample repo, then remove repo
RUN cd /tmp && hg clone https://flurischt@bitbucket.org/flurischt/sample && cd sample/Apron/apron && make && make install && cd /tmp && rm -rf sample


WORKDIR /home/sample
USER sample

# make sure the apron libs are found
ENV LD_LIBRARY_PATH=/usr/local/lib

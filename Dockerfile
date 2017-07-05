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
RUN apt-get install libgomp1 libgmp-dev libmpfr-dev libppl-dev openjdk-8-jdk build-essential python git -y

#RUN mkdir -p /opt/z3 && cd /opt/z3 && wget https://github.com/Z3Prover/z3/releases/download/z3-4.5.0/z3-4.5.0-x64-debian-8.5.zip && unzip z3-4.5.0-x64-debian-8.5.zip && ln -s `pwd`/z3-4.5.0-x64-debian-8.5/bin/z3 /usr/bin/z3
# Install Z3 (post v4.5.0).
RUN cd /tmp && \
    git clone https://github.com/Z3Prover/z3.git && \
    cd /tmp/z3 && \
    git checkout 0a0b17540f307e041a791145c2c94ab57a7b6907 && \
    ./configure && \
    cd build && \
    make && \
    make install && \
    apt-get clean && \
    rm -rf /tmp/z3

# build apron from sample repo, then remove repo
RUN cd /tmp && hg clone https://flurischt@bitbucket.org/flurischt/sample && cd sample/Apron/apron && make && make install && cd /tmp && rm -rf sample
# fix permissions that were broken by apron makefile
RUN chmod 777 /tmp

#install mono
# Install Mono.
RUN apt-get install -y mono-devel tzdata

# install boogie
#WORKDIR /usr/src
#RUN wget "http://download-codeplex.sec.s-msft.com/Download/Release?ProjectName=boogie&DownloadId=518016&FileTime=129954091212230000&Build=21050" -O Boogie.zip
#RUN mkdir boogie && mv Boogie.zip boogie/ && cd boogie && unzip Boogie.zip
#RUN printf '#!/bin/sh\n/usr/bin/mono %s/Boogie.exe "$@"\n' `pwd`/boogie > boogie/boogie && chmod +x boogie/boogie
#RUN ln -s /usr/bin/z3 /usr/src/boogie/z3.exe
# Install Boogie.
RUN wget --no-verbose 'https://github.com/boogie-org/boogie/archive/f085c05a5c49c730ca28be74b79d080f05f0b72e.zip' -O /tmp/boogie.zip && \
    cd /tmp && \
    unzip -q boogie.zip && \
    cd boogie-* && \
    wget --no-verbose https://nuget.org/nuget.exe && \
    xbuild Source/Boogie.sln && \
    mkdir -p /usr/lib/boogie/ && \
    cp -r Binaries/* /usr/lib/boogie/ && \
    echo '#!/bin/bash' > /usr/bin/boogie && \
    echo 'mono --runtime=v4.0.30319 /usr/lib/boogie/Boogie.exe "$@"' >> /usr/bin/boogie && \
    chmod 755 /usr/bin/boogie && \
    cd /usr/lib/boogie && \
    ln -s /usr/bin/z3 z3.exe && \
    apt-get clean && \
    rm -rf /tmp/*

WORKDIR /home/sample
USER sample

# make sure the apron libs are found
ENV LD_LIBRARY_PATH=/usr/local/lib
ENV Z3_EXE=/usr/bin/z3
ENV BOOGIE_EXE=/usr/bin/boogie

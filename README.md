# sample-docker-image 
A docker image containing openjdk 8, sbt, z3, Boogie and apron (including java bindings). 

This image can be used to build, test and run the [Sample](http://www.pm.inf.ethz.ch/research/sample.html) static analyzer.

## Docker Hub
There's an automated build at [Docker Hub](https://hub.docker.com/r/flurischt/sample).

## usage
 - cd to ../sample_repo_dir
 - ```sudo docker run -it --rm -v `pwd`:/home/sample/workspace flurischt/sample /bin/bash```
 - `cd workspace/sample && sbt test`
 - or try out utils/docker.sh

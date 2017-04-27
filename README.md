# sample-docker-image 
A docker image containing openjdk 8, sbt, z3 and apron (including java bindings). 

This image can be used to build, test and run the [Sample](http://www.pm.inf.ethz.ch/research/sample.html) static analyzer.

## usage
 - cd to ../sample_repo_dir
 - ```sudo docker run -it --rm -v `pwd`:/home/sample/workspace flurischt/sample /bin/bash```
 - `cd workspace/sample && sbt test`

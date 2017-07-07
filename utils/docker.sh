#!/bin/bash

#
# This script starts a shell in a docker container with all required libraries and tools to test/run Sample.
# It is assumed that the script is run inside the sample/ directory and in the parent directory the other necessary 
# projects (silver, carbon, silicon etc) are available.
#
# The container provides Z3, Boogie, apron (with java bindings), scala, sbt and java8
#
# USAGE:
#   MAKE SURE docker.sh is in the root of the Sample repository
#   > sudo ./docker.sh
#   container> cd workspace/sample && sbt "project sample-silver" test

# get the path to the parent directory of this script
PARENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

# run/create a container named sample. This call will fail on the 2nd invocation
# we map the parent directory of the current script to /home/sample/workspace in the container
docker run -td --name sample -v $PARENT_DIR:/home/sample/workspace flurischt/sample /bin/bash 2> /dev/null

# in case this is not the first invocation, the previous run failed (name already exists). Easy, just start the container
docker start sample 2> /dev/null

# then open an interactive shell in it
docker exec -it sample /bin/bash

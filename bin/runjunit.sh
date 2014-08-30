#!/usr/bin/env bash

ROOT_DIR="$( cd ../; pwd )"
LOCAL_REPO="$ROOT_DIR/.repo"


if [ -z $1 ]; then 
cat <<EOF
  Run given junit test. 
  $0 <test classname> <number of required nodes, default one>
EOF
exit 1
fi

TESTCLASS=$1
NODES=1
if [ ! -z $2 ]; then
  NODES=$2
fi
JVM="java -Xmx3g -jar target/h2o.jar"

(
  cd "$LOCAL_REPO"
  if [ ! -f "target/h2o.jar" ]; then
    ./build.sh build 1>/dev/null
  fi

  echo "Launching $NODES JVMs with H2O"
  PIDS=( )
  for N in $(seq 1 $NODES); do
    $JVM & PIDS[${#PIDS[*]}]=$!
  done
  echo "Launched PIDs: ${PIDS[@]}"
  sleep 1

  echo "Launching test..."
  $JVM -mainClass org.junit.runner.JUnitCore "$TESTCLASS"
  
  # Kill JVMs
  for i in "${PIDS[@]}"; do
    kill -9 $i
  done
)

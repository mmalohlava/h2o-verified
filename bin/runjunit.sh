#!/usr/bin/env bash

ROOT_DIR="$( cd ../; pwd )"
LOCAL_REPO="$ROOT_DIR/.repo"
BASEIP="127.0.0.1"
BASEPORT="54444"
TMP="/tmp"

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

# Generate flatfile
FLATFILE="$TMP/flatfile_$RANDOM"
# Record for test
echo "$BASEIP:$BASEPORT" > $FLATFILE
# Records for additional nodes
for N in $(seq 1 $NODES); do
  echo "$BASEIP:$(($BASEPORT + 2*$N))" >> $FLATFILE
done
# Command line
JAVA="java"
JVM_OPTS="-Xmx3g"
H2O_OPTS="-ip $BASEIP -flatfile $FLATFILE -debug"
H2O_JAR_FILE="target/h2o.jar"
JVM="$JAVA $JVM_OPTS -jar $H2O_JAR_FILE $H2O_OPTS"
echo "Command line for JVM: $JVM"
echo "Flatfile $(cat $FLATFILE)"
(
  cd "$LOCAL_REPO"
  if [ ! -f "target/h2o.jar" ]; then
    ./build.sh build 1>/dev/null
  fi

  echo "Launching $NODES JVMs with H2O"
  PIDS=( )
  for N in $(seq 1 $NODES); do
    $JVM -port $(($BASEPORT + 2*N))& PIDS[${#PIDS[*]}]=$!
    sleep 1
  done
  echo "Launched PIDs: ${PIDS[@]}"
  sleep 1

  echo "Launching test... $TESTCLASS"
  $JAVA $JVM_OPTS -Dh2o.arg.flatfile=$FLATFILE -Dh2o.arg.ip=$BASEIP -Dh2o.arg.port=$BASEPORT\
    -jar $H2O_JAR_FILE $H2O_OPTS\
    -mainClass org.junit.runner.JUnitCore "$TESTCLASS"
  
  # Kill JVMs
  for i in "${PIDS[@]}"; do
    kill -9 $i
  done
)


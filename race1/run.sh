#!/usr/bin/env bash

FIX_SHA="3969cd2"
TEST_SHA="eef4822"
TEST="src/test/java/water/TestKeySnapshotLong.java"
TESTCLASS="water.TestKeySnapshotLong"
NODES=2

ROOT_DIR="$( cd ../; pwd )"
LOCAL_REPO="$ROOT_DIR/.repo"
BIN_DIR="$ROOT_DIR/bin"

Q=

# checkout before fix
$Q $BIN_DIR/co.sh "${FIX_SHA}^"

# checkout test
( 
 cd  "$LOCAL_REPO"
 $Q git checkout "$TEST_SHA" -- "$TEST"
)
# run test
$Q $BIN_DIR/runjunit.sh "$TESTCLASS" 2


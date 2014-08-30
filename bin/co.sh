#!/usr/bin/env bash

ROOT_DIR="$( cd ../; pwd )"

GIT_REPO="https://github.com/0xdata/h2o.git"
LOCAL_REPO="$ROOT_DIR/.repo"

if [ -z $1 ]; then 
cat <<EOF
 Checkout given version of H2O.
 $0 <sha>
EOF
exit 1
fi


SHA=$1
echo "Checking SHA: $SHA"

if [ ! -d "$LOCAL_REPO" ]; then
  echo "Local repo does not exist..."
  echo "Cloning into $LOCAL_REPO"

  (
   cd "$ROOT_DIR"
   git clone "$GIT_REPO" "$LOCAL_REPO"
  )
fi

( 
  cd "$LOCAL_REPO"
  git reset --hard origin/master
  git checkout master

  git checkout $SHA
)


#!/bin/bash
set -eux

# Configuration

BASE_BRANCH=release-1.4
VERSION=1.4.8

# Set up repos as per https://github.com/istio/release-builder/blob/release-1.4/release/build.sh
# and the hashes corresponding to tags in github.com/istio/<repo> for all repos.
REPOS=(
  'istio|branch#674e254c1685b25382282da03ec17f1cf3e0ea80'
  'cni|auto#deps'
  'api|auto#modules'
)

# CI Script

CONFIG_FILE=config.yml
BUILD_IMAGE=$(curl https://raw.githubusercontent.com/istio/test-infra/${VERSION}/prow/config/jobs/release-builder.yaml | grep image | awk '{ print $2 }')
sed "s=__TEST_INFRA_IMAGE__=${BUILD_IMAGE}=" circleci_template.yml > $CONFIG_FILE

# Build Script

BUILD_BRANCH=build-$VERSION
BUILD_DIR=`mktemp -d`
MANIFEST_FILE="manifest.sh"

pushd $BUILD_DIR

echo "DEPENDENCIES=\$(cat <<EOD" >> $MANIFEST_FILE

for ENTRY in "${REPOS[@]}" ; do
  REPO="${ENTRY%%|*}"
  META="${ENTRY##*|}"
  TYPE="${META%%#*}"
  REF="${META##*#}"

  if [[ $TYPE == branch ]]; then
    git clone git@github.com:vmware-allspark/$REPO.git
    pushd $REPO
    git remote add upstream https://github.com/istio/$REPO
    git remote update
    git checkout -b $BUILD_BRANCH $REF
    git push origin $BUILD_BRANCH -f
    popd
  fi

  echo "  $REPO:" >> $MANIFEST_FILE
  echo "    git: https://github.com/vmware-allspark/$REPO" >> $MANIFEST_FILE
  if [[ $TYPE == branch ]]; then
    echo "    branch: $BUILD_BRANCH" >> $MANIFEST_FILE
  else
    echo "    $TYPE: $REF" >> $MANIFEST_FILE
  fi
done

echo "EOD" >> $MANIFEST_FILE
echo ")" >> $MANIFEST_FILE

popd

# Copy generated manifest

cp $BUILD_DIR/$MANIFEST_FILE .

# Clean up

rm -rf $BUILD_DIR

# Switch to build branch and copy build files

BUILD_SCRIPT="build_images.sh"
REMOTE_NAME="istio"

git remote rm $REMOTE_NAME || true
git remote add $REMOTE_NAME https://github.com/istio/release-builder.git
git remote update

cd ..
mkdir .circleci
cp .allspark/$CONFIG_FILE .circleci/
cp .allspark/$MANIFEST_FILE release/
cp .allspark/$BUILD_SCRIPT release/
cp .allspark/setup.sh release/setup.sh.bak

git branch -D $BUILD_BRANCH || true
git checkout -b $BUILD_BRANCH $REMOTE_NAME/$BASE_BRANCH -f
rm -rf .allspark
echo $VERSION > release/trigger-build

# Finish

echo "Setup complete!"

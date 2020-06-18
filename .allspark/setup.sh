#!/bin/bash
set +x

# Configuration

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

git checkout -b $BUILD_BRANCH || git checkout $BUILD_BRANCH
mkdir ../.circleci
cp $CONFIG_FILE ../.circleci/
cp $MANIFEST_FILE ../release/
cp $BUILD_SCRIPT ../release/
echo $VERSION > ../release/trigger-build
cd ..

# Finish

echo "Setup complete!"

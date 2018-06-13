#!/bin/bash
set -e

DEV_BRANCH=${DEV_BRANCH:-development}
VERSION_FILE=${VERSION_FILE:-runtime/version.go}

echo $DEV_BRANCH

SEMVER_REGEX="^v(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)(\\-[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?(\\+[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?$"

# ask for version if not an ENV
if [[ -z $VERSION ]];
then
  echo What version?
  read VERSION
fi

# validate the version is SemVer
if ! [[ "$VERSION" =~ $SEMVER_REGEX ]];
then
  echo $VERSION should be in the form of vx.x.x
  exit -1
fi

# confirm they want to release that version
echo "You want to release version $VERSION? [y/n]"
read CONFIRM
if ! [[ $CONFIRM == "y" ]];
then
  exit -1
fi

# if not in master, let's switch to it
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if ! [[ "master" ==  $CURRENT_BRANCH ]];
then
  git checkout master
fi

git rebase development

REVERTS=()

go install -v github.com/gobuffalo/packr/packr
packr
git add *-packr.go
git add **/*-packr.go
git commit **/*-packr.go *-packr.go * -m "committed packr files"
REVERTS+=$(git rev-parse --short HEAD)

sed -i "s/Version = \".*\"/Version = \"$VERSION\"/" $VERSION_FILE
cat $VERSION_FILE
git add $VERSION_FILE
git commit $VERSION_FILE -m "version bump $VERSION"
REVERTS+=$(git rev-parse --short HEAD)

git tag $VERSION
git push origin master
git push origin --tags

# ---
# go back to development

git branch -D $DEV_BRANCH
git checkout -b $DEV_BRANCH

git log

echo $REVERTS

for sha in $REVERTS
do
  git revert $sha
done

git push origin $DEV_BRANCH

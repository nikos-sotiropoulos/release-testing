#!/usr/bin/env bash

red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 44)
reset=$(tput sgr0)

version=$1
#name=$2
inputfile=$2

##
## Replacing tabs with spaces because they case trouble in JSON parsing GitHub API
## Replacing new lines with \n for JSON parsing
## this should all go in one awk command but not sure how!

text=$(cat $inputfile | tr -s '\t' ' ' | awk '{printf "%s\\n", $0}')
echo $text
#exit 1
branch=$(git rev-parse --abbrev-ref HEAD)
repo_full_name=$(git config --get remote.origin.url | sed 's/.*:\/\/github.com\///;s/.git$//')
token="$GITHUB_API_TOKEN"
GITHUB_API_BASE_URL="https://api.github.com"
GITHUB_API_RELEASE_URL="$GITHUB_API_BASE_URL/repos/$repo_full_name/releases"
GITHUB_PATCH_RELEASE_ID_URL="$GITHUB_API_RELEASE_URL/$3"

##
## NB: tag_name and name will most likely be the same in our case, by simple convenvtion
##
IFS='' read -r -d '' payload <<EOF
{
  "tag_name": "$version",
  "name": "$version",
  "body": "$text",
  "draft": false,
  "prerelease": false
}
EOF

printf "Create release $yellow$version$reset for repo: $blue$repo_full_name$reset branch: $green$branch$reset \n"
printf " POST url is: $GITHUB_API_RELEASE_URL \n"
printf "###################################################################################\n"
printf "Payload is \n"
echo $payload | jq
# curl -X POST -sn -d "$payload" "$GITHUB_API_RELEASE_URL"

curl -X PATCH -sn -d "$payload" "$GITHUB_PATCH_RELEASE_ID_URL"
#curl -n  https://api.github.com//repos/nikos-sotiropoulos/release-testing/releases

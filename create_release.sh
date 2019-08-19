#!/usr/bin/env bash

### list all releases
#curl -n  https://api.github.com/repos/nikos-sotiropoulos/release-testing/releases

version=$1
#name=$2
INPUTFILE=$2

#optional, if passed there will be a PATCH
RELEASE_ID=$3


echo "Script name: $0"
echo $# arguments

if [ "$#" -lt 2 ]; then
  echo "illegal number of arguments"
  exit -1
fi

red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 44)
reset=$(tput sgr0)

repo_full_name=$(git config --get remote.origin.url)

re="^(https|git)(:\/\/|@)([^\/:]+)[\/:]([^\/:]+)\/(.+).git$"

if [[ $repo_full_name =~ $re ]]; then
 protocol=${BASH_REMATCH[1]}
 separator=${BASH_REMATCH[2]}
 hostname=${BASH_REMATCH[3]}
 user=${BASH_REMATCH[4]}
 repo=${BASH_REMATCH[5]}
fi

echo $protocol
echo $separator
echo $hostname
echo $user
echo $repo

GITHUB_API_BASE_URL="https://api.github.com"
GITHUB_API_RELEASE_URL="$GITHUB_API_BASE_URL/repos/$user/$repo/releases"
GITHUB_PATCH_RELEASE_ID_URL="$GITHUB_API_RELEASE_URL/$RELEASE_ID"

##
## Replacing tabs with spaces because they case trouble in JSON parsing GitHub API
## Replacing new lines with \n for JSON parsing
## this should all go in one awk command but not sure how!
echo "Here!"

text=$(cat $INPUTFILE | tr -s '\t' ' ')
#text=$(cat $INPUTFILE | tr -s '\t' ' ' | awk '{printf "%s\\n", $0}')
echo "${text}"
echo "THERE!!!!"

#exit 1

branch=$(git rev-parse --abbrev-ref HEAD)

##
## NB: tag_name and name will most likely be the same in our case, by simple convenvtion
##
IFS='' read -r -d '' payload <<EOF
{
  "tag_name": "$version",
  "name": "$version",
  "body": "$text"
}
EOF

printf "Create release $yellow$version$reset for repo: $blue$repo_full_name$reset branch: $green$branch$reset \n"
printf " POST url is: $GITHUB_API_RELEASE_URL \n"
printf "###################################################################################\n"
printf "Payload is \n"
echo $payload | jq
#exit 1
if [ -z $RELEASE_ID ]; then
  curl -X POST -sn -d "$payload" "$GITHUB_API_RELEASE_URL"
else
  curl -X PATCH -sn -d "$payload" "$GITHUB_PATCH_RELEASE_ID_URL"
fi

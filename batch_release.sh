#!/usr/bin/env bash
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 44)
reset=$(tput sgr0)

repo_full_name=$(git config --get remote.origin.url | sed 's/.*:\/\/github.com\///;s/.git$//')
GITHUB_API_BASE_URL="https://api.github.com"
GITHUB_API_RELEASE_URL="$GITHUB_API_BASE_URL/repos/$repo_full_name/releases"
#GITHUB_PATCH_RELEASE_ID_URL="$GITHUB_API_RELEASE_URL/{RELEASE_ID}"

tag_with_git() {
  local tag=$1
  printf "Creating tag $tag... \n"
  #git tag -a $tag -m "Tag $tag is special"
}

post_release() {
  local version=$1
  local inputfile=$2
  local text=$(cat $inputfile | tr -s '\t' ' ' | awk '{printf "%s\\n", $0}')

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

  local branch=$(git rev-parse --abbrev-ref HEAD)
  printf "Create release $yellow$version$reset for repo: $blue$repo_full_name$reset branch: $green$branch$reset \n"
  #printf " POST url is: $GITHUB_API_RELEASE_URL \n"
  printf "###################################################################################\n"
  printf "Payload is \n"
  echo $payload | jq
  curl -X POST -sn -d "$payload" "$GITHUB_API_RELEASE_URL"
}


for release in $(seq -w 4 26); do
  tag="2.0.1$release"
  filename="./releases/$tag.txt"
  if [ -f $filename ]; then
   printf "File $filename exists. Do the work... \n"
   tag_with_git
   post_release $tag $filename
   # give it some time to minimise risk of 'race conditions'
   sleep 5
 else
   printf "Skipping non-existent $filename...\n"
 fi
done

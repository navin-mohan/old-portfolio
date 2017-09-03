#!/bin/bash
jekyll build
cp ./CNAME ./_site/CNAME
rm ./_site/build_and_deploy.sh
git add .
git commit -m "new build: $1"
git push origin src
git subtree push --prefix _site origin master
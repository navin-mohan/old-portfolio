#!/bin/bash
jekyll build
cp ./CNAME ./_site/CNAME
git add .
git commit -m "new build: $1"
git push origin src
git subtree push --prefix _site origin master
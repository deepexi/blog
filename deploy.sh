#!/bin/sh
git add .
git commit -m "publish blog"
git pull
git push origin master
hexo clean
hexo g
hexo d
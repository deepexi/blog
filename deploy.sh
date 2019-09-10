#!/bin/sh
git pull
git add .
git commit -m "publish blog"
git push origin master
hexo clean
hexo g
hexo d
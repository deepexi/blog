#!/bin/sh
git pull
git add .
git commit -m "发布 blog"
hexo clean
hexo g
hexo d
---
date: 2018-03-26T00:00:00Z
title: Deploy a Hugo website to gh-pages branch on GitHub
---

Follow [the instructions on Hugo's website](https://gohugo.io/hosting-and-deployment/hosting-on-github/#deployment-of-project-pages-from-your-gh-pages-branch).

<!--more-->

Initialize the `gh-pages` branch

	git checkout --orphan gh-pages
	git reset --hard
	git commit --allow-empty -m "Initializing gh-pages branch"
	git push origin gh-pages
	git checkout master

Check out existing `gh-pages` branch into `/gh-pages`

	rm -rf gh-pages
	git worktree add -B gh-pages gh-pages origin/gh-pages

#!/bin/sh
# Prepare debian/changelog for building snapshot/release package
# Depending on the package version in debian/changelog Either 
# 1) amends an existing "Prepare to build $foo version a.b.c-d~N"
# 2) makes a new commit "Prepare to build $foo version a.b.c-d~N"
# 3) makes a new commit "Release $foo version a.b.c-d"

set -e
gbp dch --auto "${1:---snapshot}"  debian
vim debian/changelog
version="$(dpkg-parsechangelog --show-field Version)"
git add debian/changelog
prerelease=$(sed -rne '1,1 s/^.*\b(UNRELEASED)\b.*$/\1/p' debian/changelog)
if [ -n "$prerelease" ]; then
	commit_msg="Prepare to build ${version}"
else
	commit_msg="Release ${version}"
fi

prev_commit_msg=`git show --pretty='%s' --no-patch`
amend=''
case "$prev_commit_msg" in
	Prepare\ to\ build)
		amend='--amend'
		;;
esac

git commit $amend -m "$commit_msg"


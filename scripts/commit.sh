git config --global user.name github-actions
git config --global user.email github-actions@github.com
git add .
git commit -m "chore: auto release $VERSION"
git push
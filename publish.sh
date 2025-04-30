#!/bin/bash

# Initialize Git if not already initialized
if [ ! -d .git ]; then
  git init
fi

# Add all files
git add .

# Commit with a basic message
git commit -m "Initial commit"

# Ask user: public or private repo?
read -p "Make repository public or private? (p=public, anything else=private): " visibility

if [ "$visibility" = "p" ]; then
  PRIVACY_FLAG="--public"
else
  PRIVACY_FLAG="--private"
fi

# Create GitHub repository, link it, and push
gh repo create $(basename $(pwd)) $PRIVACY_FLAG --source=. --remote=origin --push

alias publish_project="~/scripts/publish.sh"

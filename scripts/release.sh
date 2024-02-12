#!/usr/bin/env bash

set -exu

env | sort

scripts/update_secret.sh
scripts/build.sh
scripts/update_appcast.sh
scripts/reset_secret.sh
scripts/commit.sh
#!/usr/bin/env bash
# Simple test runner using devenv
cd "$(dirname "$0")"
exec .devenv/profile/bin/pytest "$@"

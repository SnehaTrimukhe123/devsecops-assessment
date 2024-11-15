#!/bin/sh
set -e

apk update && apk add --no-cache entr postgresql-dev musl-dev gcc

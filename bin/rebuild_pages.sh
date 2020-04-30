#!/bin/bash

curl -u matteeyah:${GITHUB_PAT} -X POST https://api.github.com/repos/Respondo/respondo/pages/builds

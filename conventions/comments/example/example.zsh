#!/usr/bin/env zsh
emulate -LR zsh
setopt errexit pipefail #[where] $ man zshoptions

##[>] config
retries=3       #[why] flaky upstream: 3 covers observed failure runs
curl_flags=(-sS --fail-with-body) #[what] silent progress, errors + body on failure

###[>] endpoints 🤖
#>[where]
#   https://api.example.io/docs
#     sections AUTH, RATE-LIMITS
#/[where]
base_url="https://api.example.io/v2"
###[<] endpoints 🤖
##[<] config

##[>] fetch
curl $curl_flags --retry $retries "$base_url/items"
##[<] fetch

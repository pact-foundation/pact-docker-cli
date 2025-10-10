#!/bin/sh

PACT_COMMANDS=" broker broker-cli help mock-service publish publish-cli stub-service verify version verifier mock-server stub-server plugin "
PACT_RUST_COMMANDS=" pact-plugin-cli pact-stub-server pact_mock_server_cli pact_verifier_cli pact-broker-cli "

# git branch detection command fails due to cve fix https://github.blog/2022-04-12-git-security-vulnerability-announced/
# fatal: unsafe repository (REPO is owned by someone else) in other workflow steps after running checkout
# https://github.com/actions/checkout/issues/766
git config --global --add safe.directory "*" 

if [ -n "$1" ] && echo "$PACT_COMMANDS" | grep -F " $1 " > /dev/null 2>&1 ; then
  # Make the pact content dynamic so a new version gets published every time
  if echo "$@" | grep "/pact/example/pacts" >/dev/null 2>&1 ; then
    echo "Generating a new version of the pact for this demo"
    cat /pact/example/pacts/pact.json | sed "s/\"1\"/\"$(date +%s)\"/g" > /tmp/pact.json
    mv /tmp/pact.json /pact/example/pacts/pact.json
  fi

  pact "$@"
elif [ -n "$1" ] && echo "$PACT_RUST_COMMANDS" | grep -F " $1 " > /dev/null 2>&1 ; then
  exec "./bin/$@"
else
  exec "$@"
fi

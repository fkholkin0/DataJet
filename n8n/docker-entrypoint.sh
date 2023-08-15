#!/bin/sh

PYTHON_REQUIREMENTS=$HOME/requirements.txt
if test -f "${PYTHON_REQUIREMENTS}"; then
    echo "Installing python requirements from ${PYTHON_REQUIREMENTS}" 
    pip3 install -r ${PYTHON_REQUIREMENTS}
else
    echo "No python requirements found in $HOME. "
fi

if [ "$#" -gt 0 ]; then
  # Got started with arguments
  exec n8n "$@"
else
  # Got started without arguments
  exec n8n
fi
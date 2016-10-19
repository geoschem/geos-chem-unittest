#!/bin/bash

if [[ -e $( readlink -f $1 ) ]]; then
  echo "Link target found."
  exitStatus=0
else
  echo "Link target not found."
  exitStatus=1
fi

exit $exitStatus

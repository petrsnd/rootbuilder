#!/bin/bash

ScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ ! -z "$(which docker)" ]; then
    if [ -z "$(docker images -q rootbuilder)" ]; then
        docker build -t rootbuilder $ScriptDir
    else
        if [ "$1" = "-f" ]; then
            docker rmi rootbuilder
            docker build -t rootbuilder $ScriptDir
        else
            >&2 echo "The rootbuilder image already exists, use -f flag to rebuild"
        fi
    fi
else
    >&2 echo "You must install docker to use this build script"
fi


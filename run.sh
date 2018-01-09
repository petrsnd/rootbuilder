#!/bin/bash

ScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if test -t 1; then
    YELLOW='\033[1;33m'
    NC='\033[0m'
fi

if [ ! -z "$(which docker)" ]; then
    if [ -z "$(docker images -q rootbuilder)" ]; then
        echo -e "${YELLOW}Building the rootbuilder container image.${NC}"
        $ScriptDir/build.sh
    fi
    if [ ! -z "$(docker ps -f name=lucid_bell -aq)" ]; then
        echo -e "${YELLOW}Restarting stopped rootbuilder_runtime container.${NC}"
        docker start -ai rootbuilder_runtime
    else
        echo -e "${YELLOW}Running the rootbuilder image as container called rootbuilder_runtime.${NC}"
        docker run -it --name rootbuilder_runtime rootbuilder
    fi
else
    >&2 echo "You must install docker to use this script"
fi


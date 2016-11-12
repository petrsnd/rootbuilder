#!/bin/bash

print_usage()
{
    cat <<EOF
USAGE: build.sh [options]
  -i   Modify configuration and exit
  -d   Download Buildroot if necessary and exit
  -c   Clean before building
  -q   Quiet mode (don't prompt)
  -h   Display help
EOF
}

BOOTSTRAPPED=false
download()
{
    if [ ! -d "$BUILDROOT_DIR" ]; then
        mkdir -p $BUILDROOT_DIR
        echo "Downloading and extracting Buildroot: version=$BUILDROOT_VERSION"
        if [ ! -z `which curl` ]; then
            curl $BUILDROOT_URL | tar -C $SCRIPT_DIR -xz
        elif [ ! -z `which wget` ]; then
            wget -q -O - --header="Accept-Encoding: gzip" $BUILDROOT_URL | tar -C $SCRIPT_DIR -xz
        else
            echo "You need to install either curl or wget" >&2
            exit 1
        fi
    else
        echo "Buildroot already installed!"
    fi
}
bootstrap()
{
    download
    echo "Installing the latest $CONFIG_FILE to $BUILDROOT_DIR"
    cp $SCRIPT_DIR/$CONFIG_FILE $BUILDROOT_DIR/.config
    BOOTSTRAPPED=true
}

# Main script
QUIET=false
while getopts ":ikdcqh" opt; do
    case $opt in
    i)
        bootstrap
        make -C $BUILDROOT_DIR nconfig
        exit $?
        ;;
    d)
        download
        exit $?
        ;;
    c)
        bootstrap
        make -C $BUILDROOT_DIR clean
        ;;
    q)
        QUIET=true
        ;;
    h)
        print_usage
        exit 0
        ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        print_usage
        exit 1
        ;;
    esac
done
if ! $BOOTSTRAPPED; then
    bootstrap
fi
if ! $QUIET; then
    read -rsp $'Press any key to run Buildroot...\n' KEY
fi

make -C $BUILDROOT_DIR V=1 BR2_JLEVEL=4

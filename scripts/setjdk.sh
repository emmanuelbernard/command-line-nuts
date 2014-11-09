#!/bin/bash

function defaultjdk {
    local vmdir=/System/Library/Frameworks/JavaVM.framework/Versions
    local ver=${1?Usage: defaultjdk <version>}

    [ -z "$2" ] || error="Too many arguments"
    [ -d $vmdir/$ver ] || error="Unknown JDK version: $ver"
    [ "$(readlink $vmdir/CurrentJDK)" != "$ver" ] || error="JDK already set to $ver"


    if [ -n "$error" ]; then
	echo $error
	return 1
    fi

    echo -n "Setting default JDK & HotSpot to $ver ... "

    if [ "$(/usr/bin/id -u)" != "0" ]; then
	SUDO=sudo
    fi

    $SUDO /bin/rm /System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK
    $SUDO /bin/ln -s $ver /System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK
   
    echo Done.
}

function setjdk {
    local vmdir=/System/Library/Frameworks/JavaVM.framework/Versions
    local ver=${1?Usage: setjdk <version>}

    [ -d $vmdir/$ver ] || {
	echo Unknown JDK version: $ver
	return 1
    }

    echo -n "Setting this terminal's JDK to $ver ... "

    # Pre Oracle JDK, JDK is under /Home, not anymore
    export JAVA_HOME=$vmdir/$ver/Home
    if [ ! -d "$JAVA_HOME" ]; then
        export JAVA_HOME=$vmdir/$ver
    fi

    PATH=$(echo $PATH | tr ':' '\n' | grep -v $vmdir | tr '\n' ':')
    export PATH=$JAVA_HOME/bin:$PATH
   
    java -version
}

function _setjdk_completion (){
    COMPREPLY=()

    local vmdir=/System/Library/Frameworks/JavaVM.framework/Versions
    local cur=${COMP_WORDS[COMP_CWORD]//\\\\/}
    local options=$(cd $vmdir; ls | grep 1. | tr '\n' ' ')

    COMPREPLY=($(compgen -W "${options}" ${cur}))
}

complete -F _setjdk_completion -o filenames setjdk
complete -F _setjdk_completion -o filenames defaultjdk

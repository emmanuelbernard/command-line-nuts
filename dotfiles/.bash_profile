LANG="en_US.UTF-8"

#Aliases and terminal colors
alias ll='ls -al'
alias marked='open -a Marked'
alias git=hub
# add in path rather than alias otherwise Git fails to open it
alias 'postgres-start'='pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start'
alias 'postgres-stop'='pg_ctl -D /usr/local/var/postgres stop -s -m fast'

export CLICOLOR=1
export LSCOLORS=gxfxcxdxbxegedabagacad
export EDITOR=vim
alias crontab="export EDITOR=vim;crontab" #crontab does not like mvim -f

#tab title in iTerm

function local_dir_and_within {
  __LAST="${PWD##*/}"
  __IN="${PWD%/*}"
  __IN="${__IN/#$HOME/~}"
  TITLE_TAB="$__LAST in $__IN"
  echo -n $TITLE_TAB
}
export PROMPT_COMMAND='echo -ne "\033]0;$(local_dir_and_within)\007"'

#Add Macport to the path
PATH=/opt/local/bin:/opt/local/sbin:$PATH
export MANPATH=/opt/local/share/man:$MANPATH
PATH=$PATH:/Applications/MacPorts/KDE4/po2xml.app/Contents/MacOS:/Applications/MacPorts/KDE4/xml2pot.app/Contents/MacOS

#Give /usr/local priority
PATH=/usr/local/sbin:/usr/local/bin:/Applications/Sublime\ Text\ 2.app/Contents/SharedSupport/bin:$PATH
#Personal scripts
PATH=~/usr/local/bin:~/usr/local/bin/shared:$PATH

#Keychain / ssh-agent
# if not in the agent, prompt for th ekey to be added
ssh-add -l | grep 4096 | grep --quiet id_rsa
if [[ "$?" -ne "0" ]]; then
  ssh-add ~/.ssh/id_rsa
  eval `keychain --eval --agents ssh --inherit any id_rsa`
fi

#Java
export JAVA_HOME=`/usr/libexec/java_home -v 1.7`
export PATH=$JAVA_HOME/bin:$PATH

#set jdk routines
source ~/usr/local/bin/shared/setjdk.sh

#Gradle, Maven, Ant, Forge
# Brew put the executables for gradle, mvn and ant in /usr/local/bin, no need to update it anymore
export GRADLE_HOME=/usr/local/Cellar/gradle/1.10
export MAVEN_HOME=/usr/local/Cellar/maven/3.2.3
export ANT_HOME=/Developer/Java/apache-ant-1.9.4
export PATH=$GRADLE_HOME/bin:$MAVEN_HOME/bin:$ANT_HOME/bin:$PATH
export GRADLE_OPTS="-Xmx1024M"
export MAVEN_OPTS="-Xmx1024m -XX:MaxPermSize=256m"
#export MAVEN_OPTS="-Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005"

# docker
export DOCKER_HOST=tcp://localhost:4243
function docker_fwd_port {
    VBoxManage modifyvm "boot2docker-vm" --natpf1 "tcp-port$1,tcp,127.0.0.1,$1,,$1"
}
function docker_delete_fwd_port {
    VBoxManage modifyvm "boot2docker-vm" --natpf1 delete "tcp-$1"
}

#Git completion
GIT_COMPLETION_PATH="/usr/local/etc/bash_completion.d/git-completion.bash"
GIT_PROMPT_PATH="/usr/local/etc/bash_completion.d/git-prompt.sh"
if [ -f "$GIT_COMPLETION_PATH" ]; then
   GIT_PS1_SHOWDIRTYSTATE=true
   . "$GIT_PROMPT_PATH"
   . "$GIT_COMPLETION_PATH"
   ADD_PS1='$(__git_ps1)'
fi
#docker completion
COMPL=/usr/local/etc/bash_completion.d/docker
if [ -f "$COMPL" ]; then
    . "$COMPL"
fi
#tmux completion
COMPL=/usr/local/etc/bash_completion.d/tmux
if [ -f "$COMPL" ]; then
    . "$COMPL"
fi

if [[ ${EUID} == 0 ]] ; then
      PS1="\[\033[01;31m\]\h\[\033[01;34m\] \W\[\033[33m\]$ADD_PS1\[\033[34m\] \$\[\033[00m\] "
else
      PS1="\[\033[00;32m\]\u@\h\[\033[01;34m\] \W\[\033[33m\]$ADD_PS1\[\033[34m\] \$\[\033[00m\] "
fi

# RVM
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

test -f $HOME/.bash_profile_local && source $HOME/.bash_profile_local

alias a='alias'
cc-o () { cc "$@".c -o "${!#}" ; }
cdl () { cd "$@" && ls ; }
cdll () { cd "$@" && ls -l ; }
cl () { cd "$@" && ls ; }
cll () { cd "$@" && ls -l ; }
f () { find . -name "$@" -print ; }
alias ec='emacsclient'
ej () { emacsclient -cqe '(direx:jump-to-directory-with-context "'$1'" "'$2'")' > /dev/null ; }
em () { emacs $@ ; }
emj () { emacs --eval '(direx:jump-to-directory-with-context "'$1'" "'$2'")'  ; }
alias h='history'
alias hg='h | grep'
alias j='jobs -l'
llm () { ls -l "$@" | more ; }
lm () { ls "$@"| more ; }
alias lr='ls -AlRF'
lrm () { ls -AlRF "$@" | more ; }
alias lsf='ls -F'
alias lsr='ls -R'
alias lst='ls -Alrt'
alias m='more'
alias manu='man -u'
mcd () { if [ $# != 1 ]; then echo "${FUNCNAME}: expecting one arg - newdir" > /dev/stderr; return 1; fi; mkdir -p "$1" && cd "$1" ; }
alias md='mkdir -p'
p () { pushd +"$@" ; }
alias po='popd'
pol () { popd "$@" && ls ; }
poll () { popd "$@" && ll ; }
alias psf='ps -f'
psg () { ps -ef | grep "$@" | grep -v grep ; }
psm () { ps ${@:--ef} | more ; }
alias psu='ps -fu `id -un`'
alias pu='pushd'
pul () { pushd "$@" && ls ; }
pull () { pushd "$@" && ll ; }
alias rd='rmdir'
swap () { if [ $# != 2 ]; then echo "${FUNCNAME}: expecting two args - file1 file2" > /dev/stderr; return 1; fi; set __tmpswapdir=`dirname "$1"` && mv "$1" $__tmpswapdir/.tmpswap.$$ && mv "$2" "$1" && mv $__tmpswapdir/.tmpswap.$$ "$2" && unset __tmpswapdir ; }
xtitle () { echo -ne "\033]0;$@\007" ; }

# other misc. config/settings

# WSL work-arounds (as of Ubuntu 18.04)
if [ `umask` -eq 0 ]
then
    umask 022
fi
if ! [ -w "/run/screen" ]
then
    export SCREENDIR=$HOME/.screen
fi
# END WSL work-arounds

FIGNORE='.o:~'
GLOBIGNORE='~'
__MY_PROMPT_START_="\n\[\033]0;\u@\h:\w\007\033[31m\]\u@\h:\[\033[35m\w \033[31m[\D{%a%d@%H:%M} #\!]\033[0m\]"
__MY_PROMPT_END_="\r\n"
PS1="$__MY_PROMPT_START_$__MY_PROMPT_END_"
PROMPT_COMMAND="check_one_time_prompt_message"

check_one_time_prompt_message () {
    if [ "$__one_time_prompt_message_" ]
    then
        echo
        echo "$__one_time_prompt_message_"
        unset __one_time_prompt_message_
    fi
}

set -b
shopt -s histreedit
shopt -s histverify
shopt -s no_empty_cmd_completion

# read local setup (if it exists and is readable)
__BASH_LOCAL_=${BASH_LOCAL:-.bash_local}
if [ -r "/$__BASH_LOCAL_" ]
then
  . "/$__BASH_LOCAL_"
elif [ -r "$HOME/$__BASH_LOCAL_" ]
then
  . "$HOME/$__BASH_LOCAL_"
fi
unset __BASH_LOCAL_

setup_for_git ()
{
    export GIT_PS1_SHOWCOLORHINTS="true"
    export GIT_PS1_SHOWDIRTYSTATE="true"
    export GIT_PS1_SHOWSTASHSTATE="true"
    export GIT_PS1_SHOWUNTRACKEDFILES="true"
    export GIT_PS1_SHOWUPSTREAM="auto"
    PROMPT_COMMAND="check_one_time_prompt_message;__git_ps1 \"$__MY_PROMPT_START_\" \"$__MY_PROMPT_END_\""
    # better make sure git PS1 routine is available...
    local git_prompt_loaded
    local git_source_file_locations
    local git_bindir_parent
    local prompt_source_file
    local completion_source_file
    if type __git_ps1 >/dev/null 2>&1
    then
      git_prompt_loaded="true"
    fi
    # load git completion for bash (and git prompt if not already loaded)
    git_source_file_locations=". $HOME/. $HOME/bin/ $my_prefix/ $my_prefix/bin/ $my_mach_dep_prefix/ $my_mach_dep_prefix/bin/"
    if type -Pf git >/dev/null 2>&1
    then
        git_bindir_parent=$(dirname $(dirname $(type -Pf git)))
        if [ "$git_bindir_parent" = "/" ]
        then
            git_bindir_parent=""
        fi
        git_source_file_locations="$git_bindir_parent/etc/ $git_bindir_parent/contrib/completion/ $git_source_file_locations"
    fi
    prompt_source_file="git-prompt.sh"
    completion_source_file="git-completion.bash"
    for d in $git_source_file_locations
    do
        if [ -r "$d$prompt_source_file" -a -r "$d$completion_source_file" ]
        then
            if [ -z "$git_prompt_loaded" ]
            then
                . "$d$prompt_source_file"
            fi
            . "$d$completion_source_file"
            break
        fi
    done
}

if type git >/dev/null 2>&1
then
    setup_for_git
fi

# check for homeshick
if [ -r ~/.homesick/repos/homeshick ]
then
    if [ -r ~/.homesick/repos/homeshick/homeshick.sh ]
    then
        . ~/.homesick/repos/homeshick/homeshick.sh
    fi
    if [ -r ~/.homesick/repos/homeshick/completions/homeshick-completion.bash ]
    then
        . ~/.homesick/repos/homeshick/completions/homeshick-completion.bash
    fi
    if ! homeshick --quiet --batch refresh
    then
        __homeshick_refresh_warning_="Homeshick refresh: check for updates..."
        if [ "$DISPLAY" ] && type xmessage >/dev/null 2>&1
        then
            xmessage $__homeshick_refresh_warning_
        else
            __one_time_prompt_message_=$__homeshick_refresh_warning_
        fi
        unset __homeshick_refresh_warning_
    fi
fi

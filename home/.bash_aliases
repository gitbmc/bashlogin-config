alias a='alias'
cc-o () { cc "$@".c -o "${!#}" ; }
cdl () { cd "$@" && ls ; }
cdll () { cd "$@" && ls -l ; }
cl () { cd "$@" && ls ; }
cll () { cd "$@" && ls -l ; }
f () { find . -name "$@" -print ; }
alias ec='emacsclient'
alias ew='emacsclientw'
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

umask 022 # WSL Ubuntu 18.04 seems to neglect setting a non-zero value for this

FIGNORE='.o:~'
GLOBIGNORE='~'
PS1="\[\033]0;\u@\h:\w\007\033[31m\]\u@\h:\[\033[35m\w \033[31m[\!]\033[0m\]
"

set -b
shopt -s histreedit
shopt -s histverify
shopt -s no_empty_cmd_completion

# read local setup (if it exists and is readable)
__LOCALSHRC_=${LOCALSHRC:-.localshrc}
if [ -r "/$__LOCALSHRC_" ]
then
  . "/$__LOCALSHRC_"
elif [ -r "$HOME/$__LOCALSHRC_" ]
then
  . "$HOME/$__LOCALSHRC_"
fi
unset __LOCALSHRC_

setup_for_git ()
{
    export GIT_PS1_SHOWCOLORHINTS="enabled"
    PROMPT_COMMAND='__git_ps1 "\n\[\033]0;\u@\h:\w\007\033[31m\]\u@\h:\[\033[35m\W \033[31m[\D{%a%d@%H:%M} #\!]\033[0m\]" "\r\n"'
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
if [ -r ~/.homesick/repos/homeshick/homeshick.sh ]
then
    . ~/.homesick/repos/homeshick/homeshick.sh
    . ~/.homesick/repos/homeshick/completions/homeshick-completion.bash
fi

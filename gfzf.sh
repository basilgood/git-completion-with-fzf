# bash history
bind '"\C-r": "\C-x1\e^\er"'
bind -x '"\C-x1": __fzf_history'
# --multi --reverse | awk '{print ($0+0)}' | xargs

__history_d() {
  history -n
  history |
    fzf \
    --tac \
    --tiebreak=index \
    --multi --reverse | awk '{print ($0+0)}' | xargs
}
bind '"\er": redraw-current-line'
bind '"\C-q": "$(__history_d)\e\C-e\er"'

__fzf_history() {
  history -n; history -r
  __ehc $(history |
    fzf \
    --reverse \
    --multi \
    --no-sort \
    --height 40% \
    --tac \
    --tiebreak=index |
    perl -ne 'm/^\s*([0-9]+)/ and print "!$1"')
}

__ehc() {
  if
    [[ -n $1 ]]
  then
    bind '"\er": redraw-current-line'
    bind '"\e^": magic-space'
    READLINE_LINE=${READLINE_LINE:+${READLINE_LINE:0:READLINE_POINT}}${1}${READLINE_LINE:+${READLINE_LINE:READLINE_POINT}}
    READLINE_POINT=$((READLINE_POINT + ${#1}))
  else
    bind '"\er":'
    bind '"\e^":'
  fi
}

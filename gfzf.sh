# bash history
bind '"\C-r": "\C-x1\e^\er"'
bind -x '"\C-x1": __fzf_history'

hstr="history | fzf --tac --tiebreak=index | perl -ne 'm/^\s*([0-9]+)/ and print '!$1'"
delhstr="history -d "

__fzf_history() {
  history -n
  hstr
}

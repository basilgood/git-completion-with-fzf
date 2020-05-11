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

# explorer
ez() {
  files=()
  while IFS= read -r -d '' file; do
    files+=("$file")
  done < <(fzf --multi --print0)

  (( ${#files} )) || return
  "${VISUAL:-${EDITOR:-vi}}" "$@" "${files[@]}"
}

# watch dir with inotify-tools
watchdir() {
  inotifywait -rme modify --format '%w%f' "$1"
}
# Depends on inotifywait, from inotify-tools

# Usage: watchrun dir... -- command...
# e.g. watchrun src -- ctags -a

# dirs=()
# until [[ $1 == -- ]]; do
#   dirs+=("$1")
#   shift
# done
# shift
# rest=("$@")
#
# inotifywait -rme modify --format '%w%f' "${dirs[@]}" | while read -r filename; do
# <&2 echo "Running for ${filename##*/}..."
# "${rest[@]}" "$filename"
# <&2 echo "Done."
# done

# for existing man pages
fzf_apropos() {
  apropos '' | fzf --preview-window=up:50% --preview 'echo {} | cut -f 1 -d " " | xargs man' | cut -f 1 -d " "
}

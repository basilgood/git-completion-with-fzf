# from junnegun examples
# source this file in bashrc

# fshow_preview - git commit browser with previews
fshow_preview() {

  local _gitLogLineToHash="echo -n {1} | head -1"
  local _viewGitLogLine="$_gitLogLineToHash | xargs -I % sh -c 'git show --color=always % | less -R'"
  local _viewPreview="$_gitLogLineToHash | xargs -I % sh -c '(git show --stat --color=always % && echo '' && git show --color=always %) | less -R'"

    git log --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr% C(auto)%an" |
        fzf --no-sort --reverse --tiebreak=index --no-multi \
            --ansi --preview="$_viewPreview" \
                --header "enter to view, alt-y to copy hash" \
                --bind "enter:execute:$_viewGitLogLine   | less -R" \
                --bind "alt-y:execute:$_gitLogLineToHash | wl-copy"
}

_fzf_complete_git() {
    ARGS="$@"

    # these are commands I commonly call on commit hashes.
    # cp->cherry-pick, co->checkout

    if [[ $ARGS == 'git cp'* || \
          $ARGS == 'git cherry-pick'* || \
          $ARGS == 'git co'* || \
          $ARGS == 'git checkout'* || \
          $ARGS == 'git reset'* ]]; then
        _fzf_complete "--reverse --multi" "$@" < <(__git_log)
    fi
}

_fzf_complete_git_post() {
    sed -e 's/^[^a-z0-9]*//' | awk '{print $1}'
}

gh () {
    git rev-parse --is-inside-work-tree > /dev/null 2>&1 || return
    local item
    __git_log |
    fzf --height '50%' "$@" --border --ansi --no-sort --reverse --multi |
    grep -o "[a-f0-9]\{7,\}" |
    head -n1 |
    while read item; do echo -n "${(q)item} "; done
}

fzf-down() {
  fzf --height 90% "$@" --reverse
}

is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

gf() {
  is_in_git_repo || return
  git -c color.status=always status --short |
  fzf-down -m --ansi --nth 2..,.. \
    --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500' |
  cut -c4- | sed 's/.* -> //'
}

gb() {
  is_in_git_repo || return
  git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf-down --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -200' |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##'
}

gt() {
  is_in_git_repo || return
  git tag --sort -version:refname |
  fzf-down --multi --preview-window right:70% \
    --preview 'git show --color=always {} | head -200'
}

gh() {
  is_in_git_repo || return
  git-foresta --all --style=10 |
  fzf-down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always | head -200' |
  grep -o "[a-f0-9]\{7,\}"
}

gr() {
  is_in_git_repo || return
  git remote -v | awk '{print $1 "\t" $2}' | uniq |
  fzf-down --tac \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1} | head -200' |
  cut -d$'\t' -f1
}

gs() {
  is_in_git_repo || return
  git stash list | fzf-down --reverse -d: --preview 'git show --color=always {1}' |
  cut -d: -f1
}

# __fzf_history() {
#   builtin history -n;
#   builtin typeset \
#     READLINE_LINE_NEW="$(
#       HISTTIMEFORMAT= builtin history |
#         command fzf +s --height 40% \
#         --reverse --tac +m -n2..,.. \
#         --tiebreak=index \
#         --toggle-sort=ctrl-r |
#         command sed '
#               /^ *[0-9]/ {
#               s/ *\([0-9]*\) .*/!\1/;
#               b end;
#             };
#           d;
#           : end
#           '
#           )";
#
#           if
#             [[ -n $READLINE_LINE_NEW ]]
#           then
#             builtin bind '"\er": redraw-current-line'
#             builtin bind '"\e^": magic-space'
#             READLINE_LINE=${READLINE_LINE:+${READLINE_LINE:0:READLINE_POINT}}${READLINE_LINE_NEW}${READLINE_LINE:+${READLINE_LINE:READLINE_POINT}}
#             READLINE_POINT=$(( READLINE_POINT + ${#READLINE_LINE_NEW} ))
#           else
#             builtin bind '"\er":'
#             builtin bind '"\e^":'
#           fi
#         }
#
# builtin set -o histexpand;
# builtin bind -x '"\C-x1": __fzf_history';
# builtin bind '"\C-r": "\C-x1\e^\er"'

if [[ $- =~ i ]]; then
  bind '"\er": redraw-current-line'
  bind '"\C-g\C-f": "$(gf)\e\C-e\er"'
  bind '"\C-g\C-b": "$(gb)\e\C-e\er"'
  bind '"\C-g\C-t": "$(gt)\e\C-e\er"'
  bind '"\C-g\C-h": "$(gh)\e\C-e\er"'
  bind '"\C-g\C-r": "$(gr)\e\C-e\er"'
  bind '"\C-g\C-s": "$(gs)\e\C-e\er"'
fi

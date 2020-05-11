# from junnegun examples
# source this file in bashrc

is_in_git_repo() {
  git rev-parse HEAD >/dev/null 2>&1
}

gh() {
  is_in_git_repo || return
  local item
  __git_log |
    fzf --height '50%' "$@" --border --ansi --no-sort --reverse --multi |
    --bind "ctrl-s:toggle-sort" \
    --bind "ctrl-j:preview-down,ctrl-k:preview-up" \
    grep -o "[a-f0-9]\{7,\}" |
    head -n1 |
    while read item; do echo -n "\${(q)item} "; done
}

fzf-down() {
  fzf --height 90% "$@" --reverse
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

if [[ $- =~ i ]]; then
  bind '"\er": redraw-current-line'
  bind '"\C-g\C-f": "$(gf)\e\C-e\er"'
  bind '"\C-g\C-b": "$(gb)\e\C-e\er"'
  bind '"\C-g\C-t": "$(gt)\e\C-e\er"'
  bind '"\C-g\C-h": "$(gh)\e\C-e\er"'
  bind '"\C-g\C-r": "$(gr)\e\C-e\er"'
  bind '"\C-g\C-s": "$(gs)\e\C-e\er"'
fi
#
#
#
#
#  _git_commands=(add am cherry-pick commit branch format-patch ls-files help remote merge pull push amend grep rebase reset revert bisect diff difftool blame log checkout fetch stash status wdiff config)
#  _git_aliase=`git config --get-regexp 'alias.*' | sed -e 's,alias.,,' | cut -d' ' -f1`
#
# complete git "p/1/($_git_commands $_git_aliase)/" \
#   "n/help/($_git_commands $_git_aliase)/" \
#   'n/add/`git status --porcelain|cut -c4-|xargs echo`/' \
#   'n/br/`git branch|cut -c 3-`/' 'N/br/`git branch|cut -c 3-`/' \
#   'n/branch/`git branch|cut -c 3-`/' 'N/branch/`git branch|cut -c 3-`/' \
#   'n/cb/`git branch|cut -c 3-`/' \
#   'n/cherry-pick/`(git branch|cut -c3-);(git branch|cut -c3-|xargs -ibranch git log -n 100 --pretty=format:%+h branch|sort -u)`/' \
#   'n/co$/`git branch|cut -c 3-`/' \
#   'n/config/(--global --get-regexp --list)/' \
#   'n/diff/(--color-words --name-only)/' \
#   'n/difftool/(--no-prompt --prompt --tool)/' \
#   'n/fetch/`git remote`/' \
#   'n/format-patch/`(echo --output-directory --stdout --signoff);(git branch|cut -c3-);(git branch|cut -c3-|xargs -ibranch git log -n 100 --pretty=format:%+h branch|sort -u)`/' \
#   'n/log/`git branch|cut -c 3-|xargs echo -- --name-only --name-status --reverse --committer= --no-color --relative --ignore-space-change --ignore-space-at-eol --format=medium --format=full --format=fuller --color --decorate --oneline --summary`/' \
#   'n/lg/`git branch|cut -c 3-|xargs echo -- --name-only --name-status --reverse --committer= --no-color --relative --ignore-space-change --ignore-space-at-eol --format=medium --format=full --format=fuller --color --decorate --oneline --summary`/' \
#   'n/ls-files/(--cached --deleted --others --ignored --stage --unmerged --killed --modified --error-unmatch --exclude= --exclude-from= --exclude-standard --exclude-per-directory= --full-name --abbrev)/' \
#   'n/merge/`git branch|cut -c 3-|xargs echo --no-commit --no-ff --ff-only --squash`/' \
#   'N/merge/`git branch|cut -c 3-`/' \
#   'n/pull/(--rebase --no-ff --squash)/' \
#   'n/push/`git remote`/' 'N/push/`git branch|cut -c 3-`/' \
#   'n/rebase/`git branch|cut -c 3-| xargs echo --continue --abort --onto --skip --interactive`/' \
#   'N/rebase/`git branch|cut -c 3-`/' \
#   'n/remote/(show add rm prune update)/' 'N/remote/`git remote`/' \
#   'n/reset/(HEAD^)/' \
#   'N/reset/(HEAD^)/' \
#   'n/revert/`(echo --edit --no-edit --no-commit --mainline);(git branch|cut -c3-);(git branch|cut -c3-|xargs -ibranch git log -n 100 --pretty=format:%+h branch|sort -u)`/' \
#   'n/stash/(apply list save pop clear show drop create branch)/' \

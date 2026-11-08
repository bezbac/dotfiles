#!/usr/bin/env zsh

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

unalias wts 2>/dev/null
function wts() {
  local -a switch_args
  local branch='' arg remote_branch
  local expect_value=false passthrough=false exists=false

  for arg in "$@"; do
    if $passthrough; then
      switch_args+=("$arg")
      continue
    fi
    if $expect_value; then
      switch_args+=("$arg")
      expect_value=false
      continue
    fi
    case "$arg" in
      --) passthrough=true ;;
      -c|--create) continue ;;
      -b|--base|-x|--execute|-C|--config|--config-set|--format)
        expect_value=true
        ;;
      -) branch="$arg" ;;
      -*) ;;
      *)
        if [[ -z "$branch" ]]; then branch="$arg"; fi
        ;;
    esac
    switch_args+=("$arg")
  done

  case "$branch" in
    ''|'^'|'-'|'@'|pr:*|mr:*|*://*) exists=true ;;
    *)
      if [[ -d "$branch" ]] ||
        git show-ref --verify --quiet "refs/heads/$branch" ||
        git show-ref --verify --quiet "refs/remotes/$branch"; then
        exists=true
      else
        while IFS= read -r remote_branch; do
          if [[ "$remote_branch" == "$branch" ]]; then
            exists=true
            break
          fi
        done < <(git for-each-ref --format='%(refname:strip=3)' refs/remotes)
      fi
      ;;
  esac

  if $exists; then
    wt switch -x opencode "${switch_args[@]}"
  else
    wt switch -x opencode --create "${switch_args[@]}"
  fi
}

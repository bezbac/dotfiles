# Colors:
# Yellow: ffbf00
# Aquamarine: 7fffd4

function parse_git_branch -d "Parse current Git branch name"
  command git symbolic-ref --short HEAD ^/dev/null;
    or echo (command git show-ref --head -s --abbrev HEAD)[1]
end

function parse_current_folder -d "Replace '$HOME' with '~'"
  string replace $HOME '~' $PWD
end

function fish_prompt

  # Clear line
  printf "\033[K"

  # Time
  printf (date "+$c2%H$c0:$c2%M$c0:$c2%S ")

  # User
  set_color 7fffd4
  printf (whoami)
  printf " "

  set_color blue
  printf (parse_current_folder)
  printf " "

  set_color ffbf00
  set -l is_git_repository (command git rev-parse --is-inside-work-tree ^/dev/null)
  if test -n "$is_git_repository"
    printf (parse_git_branch)
    printf " "
  end

  set_color normal
  printf "› "
end

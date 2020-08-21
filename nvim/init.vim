let configs = [
\  "general",
\  "plugins",
\  "plugin-settings",
\  "lightline",
\]
for file in configs
    let x = expand("~/.config/nvim/config/".file.".vim")
    if filereadable(x)
        execute 'source' x
    endif
endfor

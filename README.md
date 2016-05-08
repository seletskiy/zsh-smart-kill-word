# Smart Backward Kill Word Widget

![demo](https://raw.githubusercontent.com/seletskiy/zsh-smart-kill-word/master/smart-kill-word.gif)

# Installation

## zgen

### Setup plugin

```zsh
zgen load seletskiy/zsh-smart-kill-word
```

### .zshrc

```zsh
bindkey '^W' smart-kill-word
bindkey '^S' smart-kill-word
```

# Settings

Following settings are unset by default:

`zstyle ':zle:smart-kill-word' precise`:
* `always` &mdash; behave same inside quotes as outside of them;

`zstyle ':zle:smart-kill-word' keep-slash`:
* `on` &mdash; keep slash after erasing word inside path;

system_name=$(uname -s)

if [[ $system_name == 'Darwin' ]]; then
  if [[ -f $HOME/.bin/custom-variables ]]; then
    source $HOME/.bin/custom-variables
  fi

  export NVM_DIR="$HOME/.nvm"
  export EMACSPATH=/usr/local/Cellar/emacs-plus/25.3/bin
  export ZSH_GIT_PROMPT=$HOME/.zsh-git-prompt
  export PATH=$HOME/.bin:/usr/local/bin:$ZSH_GIT_PROMPT/src/.bin:$EMACSPATH:$PATH

  # Configure pyenv
  if [[ $(command-exist pyenv) == 0 ]]; then
    eval "$(pyenv init -)"
    pyenv shell 3.5.4
  fi

  # Config homebrew
  export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles
  export HOMEBREW_NO_AUTO_UPDATE=true

  # Clang aliases
  alias clo='clang -o a.out '
  # Mongo aliases
  alias mongod2='/usr/local/Cellar/mongodb@2.6/2.6.12/bin/mongod'
  # Emacs without GUI
  alias emacs-term='emacs -nw'
  # Vim aliases
  alias vim='nvim'

elif [[ $system_name == 'Linux' ]]; then
  export ZSH_GIT_PROMPT=$HOME/.zsh-git-prompt
  export PATH=$HOME/.bin:$ZSH_GIT_PROMPT/src/.bin:/usr/local/bin:$PATH
  alias mongod='mongod'
  alias emacs='emacs'
  alias vim='nvim'

fi

source $ZSH_GIT_PROMPT/zshrc.sh

export ZSH=$HOME/.oh-my-zsh

# Do not enable auto-correct.
unsetopt correct_all
# set -o vi

ZSH_THEME="sharry"
CASE_SENSITIVE="false"
HYPHEN_INSENSITIVE="true"
DISABLE_AUTO_UPDATE="false"
DISABLE_LS_COLORS="false"
DISABLE_AUTO_TITLE="false"
ENABLE_CORRECTION="false"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="false"
# HIST_STAMPS="mm/dd/yyyy"
HISTSIZE=1000
SAVEHIST=1000
GIT_PROMPT_EXECUTABLE="haskell"
ZSH_THEME_GIT_PROMPT_CACHE="false"

export UPDATE_ZSH_DAYS=1
export LANG=en_US.UTF-8
export EDITOR='nvim'
export SSH_KEY_PATH="~/.ssh/rsa_id"

plugins=(
  git
  tmux
  iterm2
  zsh-syntax-highlighting
  #  zsh-autosuggestions
  zsh-completions
)

# Config tmux
ZSH_TMUX_AUTOSTART=false
ZSH_TMUX_AUTOQUIT=false

source $ZSH/oh-my-zsh.sh

autoload -U compinit && compinit

function load-nvm() {
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
  nvm use default 1>/dev/null 2>&1
}

function load-travis() {
  [ -f /Users/sxu204/.travis/travis.sh ] && source /Users/sxu204/.travis/travis.sh
}

function load-fzf() {
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
}

# Custom parameters
export true=0
export false=1

# If you come from bash you might have to change your $PATH.
# Attention: Please place /usr/local/bin before the default path value.
export EMACSPATH=/usr/local/Cellar/emacs-plus/25.3/bin
export PYTHONPATH=$HOME/.emacs.d/.cache/anaconda-mode/0.1.9
export PATH=$HOME/.bin:/usr/local/bin:$EMACSPATH:$PYTHONPATH:$PATH

if [[ $(command_exist pyenv) == 0 ]]; then
	eval "$(pyenv init -)"
fi

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="sharry"

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="false"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
export UPDATE_ZSH_DAYS=1

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  brew
  osx
  git
  tmux
  tmuxinator
)

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
export EDITOR='nvim'

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

system_name=$(uname -n)
if [[ $system_name == 'mac' ]]; then
	# Clang aliases
	alias clo='clang -o a.out '
	# Mongo aliases
	alias mongod2='/usr/local/Cellar/mongodb@2.6/2.6.12/bin/mongod'
	# Emacs without GUI
	alias emacs-term='emacs -nw'
	# Vim aliases
	alias vim='nvim'
	# Tmux
	alias tmux='tmux -2'
fi

if [[ $system_name == 'ubuntu' ]]; then
	alias mongod='mongod'
	alias emacs='emacs'
	alias vim='nvim'
	alias tmux='tmux -2'
fi

# set -o vi

# Config homebrew
export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles
export HOMEBREW_NO_AUTO_UPDATE=false

# Config tmux
ZSH_TMUX_AUTOSTART=false
ZSH_TMUX_AUTOQUIT=false

source $ZSH/oh-my-zsh.sh

# Do not enable auto-correct.
unsetopt correct_all

# Config node version manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# added by travis gem
# [ -f /Users/sxu204/.travis/travis.sh ] && source /Users/sxu204/.travis/travis.sh

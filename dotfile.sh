#!/bin/bash
#
# This program is used to backup or restore dot files.
#
# TODO: 1.Try to seperate all backup methods.
#       2.Flexible parameters like dotfile / -i -b ,etc.
#       3.Check Application folder for some specific apps like iTerm2.
#       4.Check the input parameters and related command like basename.
#       5.Use python to rewrite this.

###################################
# Declare some constant variables.
###################################
declare -r true=0
declare -r false=1
declare -r max_retry_count=3
declare -r default_git_commit_message='Sync latest settings.'
declare -r error_message_check_parameters="Please check parameters."

###############################
# Declare all used colors.
###############################
declare -r d_Black='\033[0;30m'
declare -r d_Red='\033[0;31m'
declare -r d_Green='\033[0;32m'
declare -r d_Yellow='\033[0;33m'
declare -r d_Blue='\033[0;34m'
declare -r d_White='\033[1;37m'
declare -r d_NC='\033[0m'

######################################
# Declare all used git repositories.
######################################
declare -r ohmyzsh=('Oh-My-Zsh' 'https://github.com/robbyrussell/oh-my-zsh')
declare -r spacemacs=('Spacemacs' 'https://github.com/SharryXu/spacemacs')
declare -r zshgitprompt=('Zsh-prompt' 'https://github.com/olivierverdier/zsh-git-prompt')
declare -r powerlinefonts=('Powerline-fonts' 'https://github.com/powerline/fonts')
declare -r nerdfonts=('Nerd-fonts' 'https://github.com/ryanoasis/nerd-fonts')
declare -r nvm=('Node Manager' 'https://github.com/creationix/nvm')
declare -r ohmytmux=('Oh-My-Tmux' 'https://github.com/SharryXu/.tmux')

#######################################
# Print common results to stdout and error
# results to stderr
# Globals:
#   d_Green
#   d_Red
#   d_Yellow
#   d_Blue
#   d_NC
# Arguments:
#   Status Code (Normal=0, Success=1, Warning=2, Error=3)
#   Output sentence
# Returns:
#   None
#######################################
function print() {
  if [ $# -eq 2 ]; then
    if [ $1 -eq 0 ]; then
      echo -e "${d_Blue}$2${d_NC}" >&1
	  elif [ $1 -eq 1 ]; then
      echo -e "${d_Green}$2${d_NC}" >&1
    elif [ $1 -eq 2 ]; then
      echo -e "${d_Yellow}$2${d_NC}" >&1 >&2
    elif [ $1 -eq 3 ]; then
      echo -e "${d_Red}$2${d_NC}" >&1
    else
      echo -e "${d_Red}Status code should only among 0, 1, 2 and 3.${d_NC}" >&1 >&2
    fi
  else
    echo -e "${d_Red}$error_message_check_parameters${d_NC}" >&1 >&2
    exit 1
  fi
}

#########################################
# Let user to answer yes-or-no question
# results to stderr
# Globals:
#   Print
# Arguments:
#   Prompt message
# Returns:
#   customer result
#########################################
function choice-yes-no() {
  if [ $# -eq 1 ]; then
    local retry_count=0
    while [[ retry_count -lt max_retry_count ]]; do
      if [[ retry_count -eq 0 ]]; then
         read -p "$1" yn
      else
         read -p "Please answer yes(y) or no(n):" yn
      fi

      case $yn in
        [Yy]* ) return $true;;
        [Nn]* ) return $false;;
        * ) print 2 "Please try again.";;
      esac

      let retry_count=retry_count+1
    done

    return $false
  else
    print 3 $error_message_check_parameters
    exit 1
  fi
}

#######################################
# Check command existed or not.
# Globals:
#   command
#   print
# Arguments:
#   Command Name
# Returns:
#   Command Exist Status
#######################################
function is_command_exist() {
  if [ $# -eq 1 ]; then
    if command -v $1 > /dev/null 2>&1; then
      return $true
    else
      return $false
    fi
  else
    print 3 $error-message
    exit 1
  fi
}

################################################
# Check whether specific server is alive or not.
# Globals:
#   ping
#   print
# Arguments:
#   Tool Name
#   Command Line Name (Optional)
# Returns:
#   None
################################################
function is_server_alive () {
  if [ $# -eq 1 ]; then
    local tryCounts = 3
    local result=$(ping $1 -c $tryCounts | grep "^\w\{2\} bytes from .*ttl=[0-9]" -c)
    if [ $result -eq $tryCounts ]; then
      return $true;
    else
      return $false;
    fi
  else
    print 3 $error_message_check_parameters
    exit 1
  fi
}

################################################################
# File copy (If the original file is newer than the target file)
# Globals:
#   basename
#   print
#   cp
# Arguments:
#   Source File Path
#   Target Folder Path
# Returns:
#   None
################################################################
function copy_file () {
  if [ $# -eq 2 ]; then
    local filename=$(basename $1)

    if [[ ! -f $1 ]]; then
      print 3 "The file: $1 is not existed."
      # TODO: Return status code
    fi

    if [[ ! -d $2 ]]; then
      print 3 "The source folder: $2 is illegal."
    fi

    if [[ -f $2/$filename ]]; then
      if [[ $1 -nt $2/$filename ]]; then
        cp $1 $2
        print 1 "File name $filename is replaced."
      else
        print 2 "File name $filename don't need to replace."
      fi
    else
      cp $1 $2
    fi
  else
    print 3 $error_message_check_parameters
    exit 1
  fi
}

################################################################
# Folder copy (If the original file is newer than the target file)
# Globals:
#   copy_file
#   print
# Arguments:
#   Source Folder Path
#   Target Folder Path
# Returns:
#   None
################################################################
function copy_folder () {
  if [ $# -eq 2 ]; then
    if [[ ! -d $1 ]]; then
      print 3 "The source folder: $1 is illegal."
      # TODO: Return status code
    fi

    if [[ ! -d $2 ]]; then
      print 3 "The target folder: $2 is illegal."
    fi

    for filePath in $1/*; do
      copy_file $filePath $2
    done
  else
    print 3 $error_message_check_parameters
    exit 1
  fi
}

################################################
# Check whether specific folder is empty or not.
# Globals:
#   find
#   print
# Arguments:
#   Folder Path
# Returns:
#   Folder Status
################################################
function is_folder_empty () {
  if [ $# -eq 1 ]; then
    local result=$(find $1 -name '*' -maxdepth 1)
    if [[ $result == $1 ]]; then
      return $true
    else
      return $false
    fi
  else
    print 3 $error_message_check_parameters
    exit 1
  fi
}

#######################################
# Using npm tool to install packages.
# Globals:
#   is_command_exist
#   npm
#   print
# Arguments:
#   Tool Name/Command Line Name
#   Command Line Name (Optional)
# Returns:
#   None
#######################################
function install_node_package() {
  if [ $# -gt 0 ]; then
    if [ $# -eq 2 ]; then
      result=$(is_command_exist $2)
    else
      result=$(is_command_exist $1)
    fi

    if [[ $result == $false ]]; then
      print 0 "Install latest version for $1..."
      npm install -g $1@latest
      print 1 "$1 has successfully been installed."
    else
      print 2 "$1 has already existed"
    fi
  else
    print 3 $error_message_check_parameters
    exit 1
  fi
}

#######################################
# Using homebrew to install tool.
# Globals:
#   brew
#   is_command_exist
#   print
# Arguments:
#   Tool Name
#   Command Line Name (Optional)
# Returns:
#   None
#######################################
function install_homebrew_package() {
  # By default, we think tool name ($1) is the command name ($2)
  if [ $# -gt 0 ]; then
    if [ $# -eq 2 ]; then
      result=$(is_command_exist $2)
    else
      result=$(is_command_exist $1)
    fi

    if [[ $result == $false ]]; then
      brew install $1
      print 1 "$1 has successfully been installed."
    else
      print 2 "$1 has already existed."
    fi
  else
    print 3 $error_message_check_parameters
    exit 1
  fi
}

#############################################
# Using Git to get latest version or clone.
# Globals:
#   git
#   print
# Arguments:
#   Local Folder Path
#   Remote Repository Name
#   Remote Repository Path
#   Branch Name (Optional)
#   Depth (Optional)
# Returns:
#   None
#############################################
function check_git_repository() {
  local currentFolder=$PWD

  # Please notice if the parameter is an array, then the number should count the array's length.
  if [ $# -ge 3 ]; then
    local repoInfo=$2
    if [ -d $1 ]; then
      if is_folder_empty $1 ; then
        print 2 "${repoInfo[0]} existed but it's empty."
        git clone ${repoInfo[1]} $1
      else
        print 0 "${repoInfo[0]} existed and now will pull the latest version."
        cd $1

        if [ $# -ge 4 ]; then
          print 1 "Checkout to branch: $4."
          git checkout $4
        fi

        git pull
        cd $currentFolder

        print 1 "${repoInfo[0]} has been successfully cloned."
      fi
    else
      print 2 "${repoInfo[0]} is not existed and now downloading..."

      if [ $# -ge 5 ]; then
        sudo git clone ${repoInfo[1]} $1 --depth $5
      else
        sudo git clone ${repoInfo[1]} $1
      fi

      print 1 "${repoInfo[0]} has been successfully downloaded."
    fi
  else
    print 3 $error_message_check_parameters
    exit 1
  fi
}

# TODO: Save package list to file and read it when you need
#######################################
# Install ruby packages.
# Globals:
#   gem
#   print
# Arguments:
#   Package name
# Returns:
#   None
#######################################
function install_ruby_package() {
  if [ $# -eq 1 ]; then
    local isExisted=$false
    read -ra installedPackages <<< $(gem list --local --no-version | sed -n '4,$p')
    for ((i = 0; i < ${#installedPackages[@]}; i += 2)); do
      if [[ ${installedPackages[$i]} == *$1* ]]; then
        isExisted=$true
        break
      fi
    done

    if [[ $isExisted == $false ]]; then
      # Need root permission to write /Library/Ruby/Gems/2.0.0
      sudo gem install $1
      print 1 "Ruby package name $1 has been successfully installed."
    else
      print 2 "Ruby package name $1 has already existed."
    fi
  else
    print 3 $error_message_check_parameters
    exit 1
  fi
}

#######################################
# Install python packages.
# Globals:
#   pip2,3
#   print
# Arguments:
#   Package name
#   Version (3=pip3, 2=pip2)
# Returns:
#   None
#######################################
function install_python_package() {
  if [ $# -eq 2 ]; then
    local isExisted=$false
    read -ra installedPackages <<< $(pip$2 list --format=columns | sed -n '3,$p')
    for ((i = 0; i < ${#installedPackages[@]}; i += 2)); do
      if [[ "${installedPackages[$i]}" == *"$1" ]]; then
        isExisted=$true
        break
      fi
    done

    if [[ $isExisted == $false ]]; then
      pip$2 install --user $1
      print 1 "Python package name $1 has been successfully installed."
    else
      print 2 "Python package name $1 has already existed."
    fi
  else
    print 3 $error_message_check_parameters
    exit 1
  fi
}

#######################################
# Setup Mac OS Inside parameters.
# Globals:
#   print
# Arguments:
#   None
# Returns:
#   None
#######################################
function setup_macos_settings() {
  print 0 "Show full file path on the tile in Finder..."
  defaults write com.apple.finder _FXShowPosixPathInTitle -bool true && killall Finder
  # Adjust the delay time for Dock displaying
  defaults write com.apple.Dock autohide-delay -float 0
  # Adjust the LaunchPad layout
  # defaults write com.apple.dock springboard-columns -int 8
  # defaults write com.apple.dock springboard-rows -int 7
  # Adjust the transpalent value for LaunchPad
  # defaults write com.apple.dock springboard-blur-radius -int 100
  # defaults write com.apple.dock ResetLaunchPad -bool true
  # Adjust the default location for screenshots
  # defaults write com.apple.screencapture location ~/Desktop/screenshots; killall SystemUIServer
  # Adjust the default screenshot type
  # defaults write com.apple.screencapture type jpg && killall SystemUIServer
  killall Dock
}

#######################################
# Install custom commands.
# Globals:
#   copy_folder
# Arguments:
#   None
# Returns:
#   None
#######################################
function install_custom_commands() {
  if [ ! -d "$HOME/.bin" ]; then
    mkdir $HOME/.bin
  fi

  copy_folder $SourcePath/Bin $HOME/.bin
}

#######################################
# Backup custom commands.
# Globals:
#   copy_folder
# Arguments:
#   None
# Returns:
#   None
#######################################
function backup_custom_commands() {
  # TODO: Only copy executable files.
  copy_folder $HOME/.bin $SourcePath/Bin
}

#############################################
# Push git repository. (Default: master branch)
# Globals:
#   git
#   basename
#   print
# Arguments:
#   Local Repository Name
# Returns:
#   None
#############################################
function push_git_repository() {
  local currentFolder=$PWD
  local repositoryname=$(basename $1)

  if [ $# -ge 1 ]; then
    if [ -d $1 ] && ! is_folder_empty $1 ; then
	    print 0 "Please provide appropriate message:"
      read commitMessage
      if [[ -z $commitMessage ]]; then
        commitMessage=$default_git_commit_message
      fi

      cd $1

      git add .
      git commit -m "$commitMessage"
      git push

      if [ $? -eq 0 ]; then
        print 1 "Repository name $repositoryname has been successfully pushed."
      else
        print 3 "Something wrong happened when pushing the repository."
      fi

      cd $currentFolder
    fi
  else
    print 3 $error_message_check_parameters
    exit 1
  fi
}

#######################################
# Install tools and settings.
# Globals:
# Arguments:
#   None
# Returns:
#   None
#######################################
function install() {
  print 0 "Check brew..."
  local result=$(is_command_exist 'brew')
  if $result ; then
    brew update
    print 1 "brew has been successfully updated."
    print 0 "Update all brew packages..."
    brew upgrade
    print 1 "All brew packages have been updated."
  else
    result=$(is_command_exist 'ruby')
    if $result ; then
      print 3 "Please install Ruby first."
      exit 1
    else
      ruby $SourcePath/Brew/brew_install
      print 1 "brew has been successfully installed."
    fi
  fi

  print 0 "Check Ruby..."
  install_homebrew_package 'ruby'

  print 0 "Check git..."
  install_homebrew_package 'git'
  copy_file $SourcePath/Git/.gitconfig $HOME/
  copy_file $SourcePath/Git/.gitignore_global $HOME/

  print 0 "Check python3..."
  install_homebrew_package 'python3'

  print 0 "Check python2..."
  install_homebrew_package 'python2'

  print 0 "Check mongo database..."
  install_homebrew_package 'mongodb' 'mongo'
  copy_file $SourcePath/MongoDB/.mongorc.js $HOME

  print 0 "Check mysql database..."
  install_homebrew_package 'mariadb' 'mysql'
  copy_file $SourcePath/MySQL/.my.cnf $HOME

  print 0 "Check tree tool..."
  install_homebrew_package 'tree'

  print 0 "Check Oh-My-Zsh..."
  check_git_repository $HOME/.oh-my-zsh ${ohmyzsh[*]}
  copy_file $SourcePath/Zsh/.zshrc $HOME
  # install_homebrew_package 'zsh-completions'

  print 0 "Check tmux tool..."
  install_homebrew_package 'tmux'
  install_homebrew_package 'reattach-to-user-namespace'
  install_ruby_package 'tmuxinator'
  check_git_repository $HOME/.tmux ${ohmytmux[*]}
  ln -s -f $HOME/.tmux/.tmux.conf $HOME
  copy_file $SourcePath/Other/.tmux.conf.local $HOME

  # config emacs (substitute the default emacs installed by Mac OS)
  print 0 "Check emacs..."
  install_homebrew_package 'emacs'
  check_git_repository $HOME/.emacs.d ${spacemacs[*]}
  copy_file $SourcePath/Emacs/.spacemacs $HOME
  # Remove this file to avoid the strange characters in the Spacemacs' terminal mode.
  if [ -f "$HOME/.iterm2_shell_integration.zsh" ]; then
    rm $HOME/.iterm2_shell_integration.zsh
  fi
  install_python_package 'wakatime' '3'

  print 0 "Check Nerd fonts..."
  check_git_repository $HOME/.fonts-nerd ${nerdfonts[*]}
  $HOME/.fonts-nerd/install.sh 1> /dev/null

  print 0 "Check Powerline fonts..."
  check_git_repository $HOME/.fonts-powerline ${powerlinefonts[*]}
  $HOME/.fonts-powerline/install.sh 1> /dev/null

  print 0 "Check Vim..."
  install_homebrew_package 'vim --with-override-system-vim' 'vim'
  install_homebrew_package 'neovim' 'nvim'
  install_ruby_package 'neovim'
  install_python_package 'neovim' '2'
  install_python_package 'neovim' '3'
  install_node_package 'neovim'
  # Configure SpaceVim
  if [ ! -d $HOME/.SpaceVim ]; then
    curl -sLf https://spacevim.org/install.sh | bash
  fi
  copy_file $SourcePath/Vim/* $HOME/.SpaceVim.d/

  print 0 "Check ClangFormat tool..."
  install_homebrew_package 'clang-format'
  copy_file $SourcePath/Other/.clang-format $HOME

  print 0 "Check htop tool..."
  install_homebrew_package 'htop'

  print 0 "Check NodeJS..."
  install_homebrew_package 'node'
  install_homebrew_package 'npm'

  print 0 "Check Node Manager..."
  check_git_repository $HOME/.nvm $nvm
  source $HOME/.nvm/nvm.sh

  print 0 "Check hexo..."
  # TODO: Need to use 'npm list -g' to determine if packages are existed or not.
  install_node_package 'hexo-cli' 'hexo'

  print 0 "Check API BluePrint..."
  install_node_package 'drakov'
  install_node_package 'aglio'

  print 0 "Check travis..."
  install_ruby_package 'travis'

  print 0 "Check WakaTime tool..."
  copy_file $SourcePath/Other/.wakatime.cfg $HOME

  print 0 "Create custom tools..."
  install_custom_commands

  print 0 "Setup Mac OS..."
  setup_macos_settings

  print 0 "Enable Zsh settings..."
  /bin/zsh $HOME/.zshrc

  print 1 "Done."
}

#######################################
# Backup settings.
# Globals:
# Arguments:
#   None
# Returns:
#   None
#######################################
function backup() {
  print 0 "Backup Oh-My-Zsh..."
  copy_file $HOME/.zshrc $SourcePath/Zsh/

  print 0 "Backup emacs..."
  copy_file $HOME/.spacemacs $SourcePath/Emacs/

  print 0 "Backup mongo database..."
  copy_file $HOME/.mongorc.js $SourcePath/MongoDB/
  # TODO: backup mongo.conf file.

  print 0 "Backup mysql database..."
  copy_file $HOME/.my.cnf $SourcePath/MySQL/

  print 0 "Backup clang format information..."
  copy_file $HOME/.clang-format $SourcePath/Other/

  print 0 "Backup tmux tool's configuration..."
  copy_file $HOME/.tmux.conf.local $SourcePath/Other/

  print 0 "Backup Vim..."
  copy_folder $HOME/.SpaceVim.d $SourcePath/Vim

  print 0 "Backup System Config..."
  copy_folder $HOME/.config/fontconfig $SourcePath/Config/fontconfig
  copy_folder $HOME/.config/tmuxinator $SourcePath/Config/tmuxinator

  print 0 "Backup Git Configuration..."
  copy_file $HOME/.gitconfig $SourcePath/Git/
  copy_file $HOME/.gitignore_global $SourcePath/Git/

  print 0 "Backup custom tools..."
  backup_custom_commands

  print 0 "Backup WakaTime Config..."
  copy_file $HOME/.wakatime.cfg $SourcePath/Other/

  print 1 "Done."
}

declare -r manual="Usage: dotfile [Options] <source path>\n\n
[Options]:\n
-i  Install dot files to this machine.\n
-b  Backup dot files.\n
-a  Integrate backup and install."

# main program
if [ ! $# -eq 2 ]; then
  echo -e $manual
  exit 1
else
  SourcePath=$(echo $2 | sed 's/.+\/$//g')

  if [[ ${SourcePath:0:1} != '/' && ${SourcePath:0:1} != '~' ]]; then
    # Check as relative path
    SourcePath=$PWD/$(echo $SourcePath | sed 's/^\///g')
  fi

  if [ ! -d $SourcePath ] || is_folder_empty $SourcePath; then
    print 2 "$SourcePath is not existed or empty."
    echo -e $manual
    exit 1
  fi

  if [[ $1 = "-b" ]]; then
    backup

    # TODO: Add parameter to trigger this.
    #       Also, if nothing changes, we need to ignore this.
    if choice-yes-no "Do you want push to the remote?"; then
      print 0 "Push to remote git repository..."
      push_git_repository $SourcePath
    fi

    # Redirect to the Source folder
    cd $SourcePath

    # Show difference
    git diff --word-diff

    exit $?
  elif [[ $1 = "-i" ]]; then
    install
    exit $?
  elif [[ $1 = "-a" ]]; then
    backup
    install
  else
    echo -e $manual
    exit 1
  fi
fi

exit $?

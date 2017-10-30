#!/bin/bash
# This program is used to backup or restore dot files.

manual="Usage: dotfile [Options]\n\n
        [Options]:\n
        -i  Install dot files to this machine.\n
        -b  Backup dot files."

ohmyzsh='https://github.com/robbyrussell/oh-my-zsh'
spacemacs='https://github.com/SharryXu/spacemacs'
zshgitprompt='https://github.com/olivierverdier/zsh-git-prompt'
nerdfonts='https://github.com/ryanoasis/nerd-fonts'

function isProgramExisted() {
    if [ $# -eq 1 ]; then
        if command -v $1 > /dev/null 2>&1; then
            echo 1;
        else
            echo 0;
        fi
    else
        echo -1;
    fi
}

function npmInstallIfNotExist() {
    if [ $# -eq 2 ]; then
        local result=$(isProgramExisted $2)
        if [ $result -eq 1 ]; then
            echo $1 "has already existed"
       elif [ $result -eq 0 ]; then
            npm install -g $1
            echo $1 "has successfully been installed."
        else
            echo "Please indicate the program name to install" $1
        fi
    fi
}

function brewInstallIfNotExist() {
    if [ $# -eq 2 ]; then
        local result=$(isProgramExisted $2)
        if [ $result -eq 1 ]; then
            echo $1 "has already existed"
       elif [ $result -eq 0 ]; then
            brew install $1
            echo $1 "has successfully been installed."
        else
            echo "Please indicate the program name to install" $1
        fi
    fi
}

function gitCloneOrUpdate() {
    local currentFolder=$PWD
    if [ $# -eq 2 ]; then
        if [ -d $1 ]; then
            echo $1 "existed and now will pull the latest version."
            cd $1
            # TODO: Try to redirect the git output to shell itself
            git pull
            cd $currentFolder
        else
            echo "Downloading " $1 "..."
            git clone $2 $1
            echo $1 "has been successfully downloaded."
        fi
    else
        echo "Please check parameters."
    fi
}

function install() {
    echo "Check brew..."
    local result=$(isProgramExisted 'brew')
    if [ $result -eq 0 ]; then
        result=$(isProgramExisted 'ruby')
        if [ $result -eq 0 ]; then
            echo "Please install Ruby first."
        else
            /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
            echo "brew has been successfully installed."
        fi
    else
        brew upgrade
        brew update
        echo "brew has been successfully updated."
    fi

    echo "Check git..."
    brewInstallIfNotExist 'git' 'git'

    echo "Check python3..."
    brewInstallIfNotExist 'python3' 'python3'

    echo "Check mongo database..."
    brewInstallIfNotExist 'mongodb' 'mongo'
    cp ./MongoDB/.mongorc.js ~

    echo "Check mysql database..."
    brewInstallIfNotExist 'mariadb' 'mysql'
    cp ./MySQL/.my.cnf ~

    echo "Check tree tool..."
    brewInstallIfNotExist 'tree' 'tree'

    echo "Check Oh-My-Zsh..."
    gitCloneOrUpdate $HOME/.oh-my-zsh $ohmyzsh
    gitCloneOrUpdate $HOME/.zsh-git-prompt $zshgitprompt
    cp ./Zsh/.zshrc ~
    cp ./Zsh/sharry.zsh-theme ~/.oh-my-zsh/themes/

    echo "Check tmux tool..."
    installProgramingUsingBrew 'tmux' 'tmux'
    cp ./Other/.tmux.conf ~

    # config emacs (substitute the default emacs installed by Mac OS)
    echo "Check emacs..."
    brew install emacs --with-cocoa
    brew linkapps emacs
    gitCloneOrUpdate $HOME/.emacs.d $spacemacs
    cp ./Emacs/.spacemacs ~
    # Remove this file to avoid the strange characters in the Spacemacs' terminal mode.
    if [ -f "$HOME/.iterm2_shell_integration.zsh" ]; then
        rm ~/.iterm2_shell_integration.zsh
    fi

    # config fonts
    gitCloneOrUpdate $HOME/.fonts $nerdfonts
    $HOME/.fonts/install.sh

    echo "Check vim..."
    brew install vim --with-lua --with-override-system-vi
    brewInstallIfNotExist 'neovim' 'nvim'
    gem install neovim
    pip2 install --user neovim
    pip3 install --user neovim

    echo "Check clang format tool..."
    brewInstallIfNotExist 'clang-format' 'clang-format'
    cp ./Other/.clang-format ~

    echo "Check node js..."
    brewInstallIfNotExist 'node' 'node'
    brewInstallIfNotExist 'npm' 'npm'

    echo "Check hexo..."
    npmInstallIfNotExist 'hexo-cli' 'hexo'

    echo "Done."
}

function backup() {
    echo "Backup Oh-My-Zsh..."
    cp ~/.zshrc ./Zsh/
    cp ~/.oh-my-zsh/themes/sharry.zsh-theme ./Zsh/

    echo "Backup emacs..."
    cp ~/.spacemacs ./Emacs/

    echo "Backup mongo database..."
    cp ~/.mongorc.js ./MongoDB/
    #TODO: backup mongo.conf file.

    echo "Backup mysql database..."
    cp ~/.my.cnf ./MySQL/

    echo "Backup clang format information..."
    cp ~/.clang-format ./Other/

    echo "Backup tmux tool's configuration..."
    cp ~/.tmux.conf ./Other/

    echo "Done."
}

# main program
if [ $# -lt 1 -o $# -gt 1 ]
then
    echo -e $manual
elif [ "$1" = "-b" ]
then
    backup
elif [ "$1" = "-i" ]
then
    install
fi

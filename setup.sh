#!/bin/sh

echo "Checking if command line tools are installed..."

# xcode system
if [[ -z `which gcc` || -z `gcc -v 2>&1 | grep LLVM` ]]; then
  echo "Installing OSX Command Line tools"
  xcode-select --install
  read -p " ####--  Follow the dialoge and hit [Enter] once installed ---####"
else
  echo "...Command Line Tools good to go :)"
fi

# Install oh-my-zsh if zsh is not the current shell
if [[ $SHELL != '/bin/zsh' ]]; then
  echo 'Installing oh-my-zsh...'
  curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh
fi

# Install Homebrew
if [[ -z `which brew` || "`which brew`" == "brew not found" ]]; then
  echo "Installing homebew"
  ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
  echo '# HOMEBREW
export PATH=/usr/local/bin:/usr/local/sbin:$PATH' >> ~/.zshrc
else
  echo "Updating homebrew sources"
  brew update
fi

function install_brew {
  local package=$1

  local outdated=`brew outdated | grep $package`
  local installed=`brew list | grep $package`

  if [[ -z $installed ]]; then
    echo "[brew] Installing $package"
    brew install $package
  fi

  if [[ $outdated ]]; then
    echo "[brew] Upgrading $package"
    brew upgrade $package
  fi

  if [[ $installed && -z $outdated ]]; then
    echo "[brew] $package is already installed and up to date"
  fi
}

function install_brew_cask {
  local package=$1

  local installed=`brew cask list | grep $package`

  if [[ -z $installed ]]; then
    echo "[brew-cask] Installing $package"
    brew cask install $package
  fi

  if [[ $installed ]]; then
    echo "[brew-cask] $package is already installed"
  fi
}

function install_gem {
  local gem=$1

  (gem list | grep $gem > /dev/null && echo "[gem] $gem is already installed") ||
  (gem install $gem)
}

function install_ruby {
  local version=`ruby-build --definitions | grep '^\(\d\.\d\.\d\)\(-p\d*\)\{0,1\}$' | tail -1`

  (rbenv versions | grep $version > /dev/null && echo "[rbenv] Already installed Ruby $version") ||
  (echo "[rbenv] Installing Ruby $version" && rbenv install $version)
}

install_brew rbenv

install_brew ruby-build

if [[ -z `grep '\$(rbenv init' ~/.zshrc` ]]; then
  echo "Setting rbenv path in zshrc"

  echo '# RBENV
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"' >> ~/.zshrc

  export PATH="$HOME/.rbenv/bin:$PATH"
fi

if [[ !(-e ~/.gemrc) ]]; then
  echo 'install: --no-rdoc --no-ri
update:  --no-rdoc --no-ri' >> ~/.gemrc
fi

install_ruby

install_brew git

install_brew heroku-toolbelt

install_brew caskroom/cask/brew-cask # test - make sure works with update

install_brew_cask sublime-text

rbenv global 2.1.2 #bad hardcoded

eval "$(rbenv init -)" # otherwise gonna ask us fail on permission error
install_gem bundler

install_gem rbenv-autohash

echo "\033[0;32m"'                                                                                                    '"\033[0m"
echo "\033[0;32m"'                __   __   __                                              __ __         __     __   '"\033[0m"
echo "\033[0;32m"'.---.-.-----.--|  | |  |_|  |--.-----.----.-----. .--.--.--.---.-.-----. |  |__|.-----.|  |--.|  |_ '"\033[0m"
echo "\033[0;32m"'|  _  |     |  _  | |   _|     |  -__|   _|  -__| |  |  |  |  _  |__ --| |  |  ||  _  ||     ||   _|'"\033[0m"
echo "\033[0;32m"'|___._|__|__|_____| |____|__|__|_____|__| |_____| |________|___._|_____| |__|__||___  ||__|__||____|'"\033[0m"
echo "\033[0;32m"'                                                                                |_____|             '"\033[0m"
echo "\033[0;32m"'                                                                                 www.platform45.com '"\033[0m"
echo "\nAll done!"

exec /bin/zsh

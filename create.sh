#!/bin/sh

echo "Some of these commands need sudo privileges."
sudo echo "Running as administrator" # Prompts for sudo up front

echo "Checking GCC..."

if [[ -z `which gcc` || -z `gcc -v 2>&1 | grep LLVM` ]]; then
  echo "Installing OSX Command Line tools"
  xcode-system --install
else
  echo "GCC is in good order :)"
fi

# Install oh-my-zsh if zsh is not the current shell
if [[ $SHELL != '/bin/zsh' ]]; then
  echo 'Installing oh-my-zsh'
  curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh
fi

if [[ -z `which brew` || "`which brew`" == "brew not found" ]]; then
  curl -fsSkL raw.github.com/mxcl/homebrew/go | ruby
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

function install_gem {
  local gem=$1

  (gem list | grep $gem > /dev/null && echo "[gem] $gem is already installed") ||
  (gem install $gem)
}

function install_ruby {
  local version=$1

  (rbenv versions | grep $version > /dev/null && echo "[rbenv] Already installed Ruby $version") ||
  (echo "[rbenv] Installing Ruby 1.9.3-p194" && rbenv install $version)
}

install_brew rbenv
install_brew ruby-build

if [[ -z `grep '\$(rbenv init' ~/.zshrc` ]]; then
  echo "Setting rbenv path in zshrc"

  echo '# RBENV
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"' >> ~/.zshrc

  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi

if [[ !(-e ~/.gemrc) ]]; then
  echo 'install: --no-rdoc --no-ri
update:  --no-rdoc --no-ri' >> ~/.gemrc
fi

install_ruby "1.9.3-p194"

install_brew axel # Download accelerator - used in this script

install_brew ack
install_brew qt
install_brew git

# Databases
install_brew mysql
install_brew redis
install_brew memcached
install_brew sqlite

install_brew node
install_brew imagemagick

install_brew wget

rbenv global 1.9.3-p194
install_gem bundler
install_gem rbenv-autohash


if [[ !(-e ~/.pow) ]]; then
  curl get.pow.cx | sh
  echo 'export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc
else
  echo "Pow is installed.  Run 'curl get.pow.cx | sh' to ensure the latest version is installed."
fi

echo "All done!"

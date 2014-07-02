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

# Asepsis
mkdir -p ~/Downloads
if [[ -z `which asepsisctl` || -z `asepsisctl diagnose | grep OK` ]]; then
  echo "Installing Asepsis"
  axel -a http://downloads.binaryage.com/Asepsis-1.3.dmg
  mv Asepsis-1.3.dmg ~/Downloads/Asepsis-1.3.dmg
  hdiutil attach ~/Downloads/Asepsis-1.3.dmg
  sudo installer -pkg /Volumes/Asepsis/Asepsis.mpkg -target /
  hdiutil detach /Volumes/Asepsis
fi

# Postgres.app
if [[ !(-e '/Applications/Postgres.app') ]]; then
  echo "Installing Postgres.app"
  axel -a https://mesmerize.s3.amazonaws.com/Postgres/Postgres-11.zip
  mv Postgres-11.zip ~/Downloads/Postgres-11.zip
  unzip ~/Downloads/Postgres-11.zip > /dev/null
  mv Postgres.app /Applications
fi

# Sublime Text 2
if [[ !(-e '/Applications/Sublime Text 2.app') ]]; then
  echo "Installing Sublime Text 2"
  axel -a http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%202.0.1.dmg
  mv './Sublime Text 2.0.1.dmg' ~/Downloads/SublimeText.dmg
  hdiutil attach ~/Downloads/SublimeText.dmg
  cp -pR '/Volumes/Sublime Text 2/Sublime Text 2.app' /Applications
  hdiutil detach '/Volumes/Sublime Text 2/'
fi

# Sublime Text 2 Package Control
[[ -e ~/Library/Application\ Support/Sublime\ Text\ 2/Installed\ Packages/Package\ Control.sublime-package ]] ||
  (mkdir -p ~/Library/Application\ Support/Sublime\ Text\ 2/Installed\ Packages &&
    curl http://sublime.wbond.net/Package%20Control.sublime-package > ~/Library/Application\ Support/Sublime\ Text\ 2/Installed\ Packages/Package\ Control.sublime-package)

# Sublime Text 2 command line
if [[ -z `which subl` ]]; then
  ln -s "/Applications/Sublime Text 2.app/Contents/SharedSupport/bin/subl" /usr/local/bin/subl
fi

# Sublime Text 2 as system EDITOR
[[ -n `echo $EDITOR | grep subl` ]] || echo "export EDITOR='subl -w'" >> ~/.zshrc


# This must be done after Gatekeeper has been disabled since the package is unsigned
if [[ -z `ps ax | grep MouseFixer2 | grep -v grep` ]]; then
  echo "Installing MouseFixer (OSX default mouse acceleration is teh suck)"
  axel -a https://dl.dropbox.com/s/k2ka4frpnsebjfk/MouseFixer.pkg
  mv MouseFixer.pkg ~/Downloads/MouseFixer.pkg
  sudo installer -pkg ~/Downloads/MouseFixer.pkg -target /
fi

echo "All done!"

#!/bin/bash

function program_is_installed {
  # set to 1 initially
  local return_=1
  # set to 0 if not found
  type $1 >/dev/null 2>&1 || { local return_=0; }
  # return value
  echo "$return_"
}

# display a message in red with a cross by it
# example
# echo echo_fail "No"
function echo_fail {
  # echo first argument in red
  printf "\e[31m✘ ${1}"
  # reset colours back to normal
  echo -e "\033[0m"
}

# display a message in green with a tick by it
# example
# echo echo_fail "Yes"
function echo_pass {
  # echo first argument in green
  printf "\e[32m✔ ${1}"
  # reset colours back to normal
  #echo "\033[0m"
  echo -e "\033[0m"
}

# echo pass or fail
# example
# echo echo_if 1 "Passed"
# echo echo_if 0 "Failed"
function echo_if {
  if [ $1 == 1 ]; then
    echo_pass $2
  else
    echo_fail $2
  fi
}

function install_mongodb {
    echo "Installing mongodb..."
    ./install_mongodb.sh
}
function install_gatekeeper {
    echo "Installing gatekeeper..."
    ./install_gatekeeper.sh
}
function install_ruby {
    echo "Installing RVM..."
    gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
	curl -sSL https://rvm.io/mpapis.asc | gpg --import -
    \curl -sSL https://get.rvm.io | bash -s stable
    echo "Installation of RVM done."

    cd ~
    . ~/.rvm/scripts/rvm

    echo "Installing Ruby 2.2.5..."
    rvm install 2.2.5
    echo "Installation of Ruby 2.2.5 done."

    echo "Installing Bundler..."
    gem install bundler invoker
    echo "Installation of Bundler done."
}
function install_npm {
    echo "Installing NodeJS and NPM..."
    sudo apt-get install -y nodejs-legacy npm
    echo "Installation of NodeJS and NPM done."

    echo "Installing Grunt and Bower..."
    cd ../ui
	echo "You need to install manually Grunt and Grunt-cli"
#    sudo npm install -g grunt grunt-cli bower
#    echo "Installation of Grunt and Bower done."

#    sudo npm install

    echo "Installing Compass..."
    gem install compass
    echo "Installation of Compass done."

    cd ../dependencies
    echo "NPM dependencies done."
	echo "You need to move it to UI folder, and t install manually Grunt and Grunt-cli with the command: sudo npm install -g grunt grunt-cli bower"
	echo "Also, then use the following command: sudo npm install"
}

echo -e -n "\033[1;36mChecking if mongodb is installed"
mongod --version > /dev/null 2>&1
MONGO_IS_INSTALLED=$?
if [ $MONGO_IS_INSTALLED -eq 0 ]; then
    echo ">>> MongoDB already installed"
    #service mongod restart
else
    echo "Do you want to install mongodb? (y/n)"
    read install
    if [ "$install" = "y" ]; then
      echo -e -n "\033[1;31mMongodb is not installed... Installing..."
      install_mongodb
    fi
    #./install_mongodb.sh
    #bash -c "$(curl -fsSL https://raw.githubusercontent.com/steveneaston/Vaprobash/master/scripts/mongodb.sh)" bash $1 $2
fi

echo -e -n "\033[1;36mChecking if gatekeeper is installed"
if [ -f ~/go/bin/auth-utils ]; then
  echo -e -n ">>> Gatekeeper already installed."
  if [ ! -f ~/gatekeeper.cfg ]; then
    cp go/src/github.com/piyush82/auth-utils/gatekeeper.cfg ~
  fi
else
    echo "Do you want to install gatekeeper? (y/n)"
    read install
    if [ "$install" = "y" ]; then
      echo -e -n "\033[1;31mGatekeeper is not installed. Installing..."
      sudo apt-get install gcc -y
      install_gatekeeper
    fi
fi

echo -e -n "\033[1;36mChecking if ruby is installed"
. ~/.rvm/scripts/rvm
ruby --version > /dev/null 2>&1
RUBY_IS_INSTALLED=$?
if [ $RUBY_IS_INSTALLED -eq 0 ]; then
    ruby_version=`ruby -e "print(RUBY_VERSION <= '2.2.5' ? '1' : '0' )"`
    if [ $ruby_version -eq 1 ]; then
        echo "Ruby version: " $RUBY_VERSION
        echo "Please, install a ruby version higher or equal to 2.2.5"
    else
        echo ">>> Ruby is already installed"
    fi
else
    echo -e -n "\033[1;31mRuby is not installed."
    echo -e "\nDo you want to install ruby? (y/n)"
    read install
    if [ "$install" = "y" ]; then
        install_ruby
        . ~/.rvm/scripts/rvm
    fi
fi

echo -e -n "\033[1;36mChecking if nodejs is installed"
npm --version > /dev/null 2>&1
NPM_IS_INSTALLED=$?
if [ $NPM_IS_INSTALLED -eq 0 ]; then
    echo ">>> NPM is already installed"
else
    echo -e -n "\033[1;31mNPM is not installed."
    echo -e "\nDo you want to install NodeJS/NPM? (y/n)"
    read install
    if [ "$install" = "y" ]; then
        install_npm
    fi
fi

echo -e -n "\033[1;36mChecking if dependencies are installed\n"
echo "mongod          $(echo_if $(program_is_installed mongo))"
echo "ruby            $(echo_if $(program_is_installed ruby))"
echo "bundler         $(echo_if $(program_is_installed bundler))"
echo "node            $(echo_if $(program_is_installed node))"
echo "npm             $(echo_if $(program_is_installed npm))"

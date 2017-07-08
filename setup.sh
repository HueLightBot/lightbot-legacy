#!/bin/bash

# install git
apt-get install git

# install ruby via rvm
sudo apt-get install libgdbm-dev libncurses5-dev automake libtool bison libffi-dev
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
rvm install 2.2.2
rvm use 2.2.2 --default

# Set rvm to load ruby 2.2.2 on bash startup
echo "source ~/.rvm/scripts/rvm" >> ~/.bashrc
echo "rvm use 2.2.2" >> ~/.bashrc

# pull down the source and switch to it's directory
git clone https://github.com/aetaric/lightbot
cd lightbot

# install bundler if it's not already installed
gem install bundler

# install our custom twitch IRC cap cinch lib
gem install cinch-2.3.1.gem

# install bundled Gems via Gemfile
bundle install

# Prompt the user for the bridge button press
read -p "Press the button on your hue light bridge and then press enter"

# Create our API user and print out the group numbers
ruby lib/hue.rb groups

echo ""
echo "Please update config.yaml with the proper group number for your lights, the proper twitch username and oauth password, and your personal channel name."
echo ""

exit 0

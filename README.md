# lightbot
IRC bot with twitch specific features that ties into hue lights. Uses Ruby, the Cinch library, and the ruby hue library.

## Example of the bot working:
  https://clips.twitch.tv/PlumpPerfectSlothNotATK
  
## Installation:
Long term solution will be to use setup.sh to build out a working ruby env in Bash on Ubuntu on Windows. If you have an rPI or some local linux machine, you can just clone the repo on that and install the dependancies via bundler. Because of odd behavior in bundler, it doesn't like pulling the cinch library from my twitch-ready version at https://github.com/aetaric/cinch . I have provided a copy in the repo, but you can build it on your own using `gem build cinch.gemspec` in a local copy of the cinch source.

## Commands:
`cheer200 #FF0000` - Changes the color of the hue lights to #FF0000. This supports all cheermotes as well. You can use a resub or sub message to change the color as well.

`!off cheer5000`   - Turns the lights off.

`!on cheer500`     - Turns the lights on.

# lightbot
IRC bot with twitch specific features that ties into hue lights. Uses Ruby, the Cinch library, and the ruby hue library.

## Example of the bot working:
  https://clips.twitch.tv/PlumpPerfectSlothNotATK
  
## Installation:
Long term solution will be to use setup.sh to build out a working ruby env in Bash on Ubuntu on Windows. If you have an rPI or some local linux machine, you can just clone the repo on that and install the dependancies via bundler. 

Because of odd behavior in bundler, it doesn't like pulling the cinch library from my twitch-ready version at https://github.com/aetaric/cinch . I have provided a copy in the repo, but you can build it on your own using `gem build cinch.gemspec` in a local copy of the cinch source.

You'll need to auth the bot to work with your hue lights. Make sure to press your hue bridge's button less than 30 seconds before you run `ruby lib/hue.rb`. This will output the group IDs for your hue setup. Put the ID number for the group of lights you want to control in the config as `hue_group: x` where x is the ID.

## Commands:
`cheer200 #FF0000`   - Changes the color of the hue lights to #FF0000. This supports all cheermotes as well. You can use a resub or sub message to change the color as well.

`!off cheer5000`     - Turns the lights off.

`!on cheer500`       - Turns the lights on.

`!setlights #FF0000` - Forcefully sets the lights to a color. This can only be used by the broadcaster or channel mods.

## Config example:
This is a config example... Values aren't for use in production.

```yaml
---
bot:
  nick: lightbot
  password: oauth:fds78gyd290jf8whnid3v8s
  port: 6667
  server: irc.chat.twitch.tv
  cheer_floor: 200
  hue_group: 4
  channel: '#geoff'
  off_floor: 500
  on_floor: 100

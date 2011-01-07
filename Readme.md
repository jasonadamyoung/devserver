# devserver 

## Description

Devserver is a gem that provides wrapper script to launch a local webserver of your choosing (passenger, mongrel, and thin are supported, thin is the default), this grew out of [this post](http://rambleon.org/2010/11/07/refactoring-my-rails-devserver-script/).

I needed something that gave me a little more flexibility than `script/server` (or `rails server` in Rails3 ) - and because I have Rails2 and Rails3 projects, having something consistent between the two is useful for me (I can't tell you how frustrating it was to keep typing script/server in my Rails3 project before I got smart enough to dump the script).

I made it a gem because I got tired of checking it in for multiple places, and I wanted to retain the licensing of it and it's just easier to make it a gem.

Plus, I wanted to learn more about gems, and rubygems.org, and bundler, and using thor as a command line interface.  All the tools have been great to work with, especially thor (needless to say, this gem requires thor).


## Installation

$ gem install devserver

## Usage

Just run 'devserver' - thanks to the use of thor - there is usage information galore.  It needs to be cleaned more than a little.  But I wanted to get something out the door and working back to the point I was with my standalone script.

One thing that the tool will try to do is run "stop" with the server chosen if it's still running and listening on the specified port. I was running into this all the time just closing a terminal window instead of hitting control+c.

## Platforms

I do development on OS X. So I've only tested OS X. I imagine it works elsewhere. I likely will try it on Ubuntu at some point. I might do Windows 7 just for the fun of it. But like Johnny Dangerously, I'm likely to only do that once.

## TODO

Lots.  Tests, documentation cleanups, I want to tail the development.log for thin/mongrel (and maybe unicorn) just like passenger standalone does.

## License

Released under the Apache License (v2).  See LICENSE for more details.

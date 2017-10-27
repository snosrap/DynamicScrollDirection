# DynamicScrollDirection 

## Background

With Mac OS X Lion, Apple introduced the concept of "natural scrolling", in which the direction of the scroll gesture drives the direction of the on-screen scroll. I think this makes sense for trackpads (as it enhances the feeling of direct manipulation) but it still seems completely backwards when using a scroll wheel on a mouse. Ideally, I'd like my trackpad to scroll "naturally" and my mouse to scroll "traditionally". Unfortunately, while there are separate preferences for both Mouse and Trackpad scroll directions in the System Preferences app, they both map to the same `com.apple.swipescrolldirection` setting under the hood so it's impossible to have separate preferences.

DynamicScrollDirection essentially hacks around this limitation. It listens for mouse connection/disconnection events and sets the scroll direction appropriately--traditional scrolling when a mouse is attached and natural scrolling when it is removed.

## Installation

Nothing fancy -- put the compiled binary somewhere sensible (e.g., `/usr/local/bin/DynamicScrollDirection`) and install the launchd plist file: `launchctl load com.snosrap.DynamicScrollDirection.plist`.

## Alternatives

If you'd prefer a GUI, check out [Scroll Reverser](https://pilotmoon.com/scrollreverser/), which is also [open source](https://github.com/pilotmoon/Scroll-Reverser).
MacOS widget for changing scenes on a Nanoleaf Shapes instance.

Uses Swift, built in XCode 15 for macOS Sonoma.

## Build and use

In XCode, build with Product | Archive, then Distribute App,
Custom, Copy App, and export to the filesystem. This should
generate an app file.

Then add to your desktop by right-clicking on the desktop,
selecting Edit Widget, and add "Nanoleaf widget"

The first time you run it, it will attempt to locate a Nanoleaf
Shapes, save its IP address, and authenticate with it. To
successfully authenticate, the Shapes must be in pairing mode -
hold down the power button for five seconds until the controller
starts flashing its lights.

The IP address and auth token are stored in a .plist file at:

`~/Library/Preferences/net.surguy.nanoleaf-widget.plist`

You can check the saved values with:

```
defaults read net.surguy.nanoleaf-widget.plist ipAddressAndPort
defaults read net.surguy.nanoleaf-widget.plist authToken
```

or delete them by using `delete` not `read`.


## Known issues

The app window occasionally appears, even though the app is
set to be background only (particularly when finding the device
to start with). Close it if it hangs around.

You might need to click on a link twice to get the authentication
token; the first time the IP address will be found, and the second
time the auth token will be saved, hopefully.

You can't yet alter the scene names without recompiling - this
should be coming from the config.


## License

Copyright (C) 2023 Inigo Surguy

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

# Acknowledgements

This is using the Nanoleaf API (documented at https://forum.nanoleaf.me/docs)
but is not written or supported by Nanoleaf and I have no connection with them
apart from using their API.

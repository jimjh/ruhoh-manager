[![Build Status](https://secure.travis-ci.org/jimjh/ruhoh-manager.png)][1]
[![Code Climate](https://codeclimate.com/badge.png)][2]

# Download
If you wish to run the unit tests, clone the submodules as well:
```bash
$> git clone git@github.com:jimjh/ruhoh-manager.git
$> git submodule init
$> git submodule update
```

To use, install the gem and create a config.ru file in your blog repository that contains the following:
```ruby
require 'rack'
require 'ruhoh-manager'
run Ruhoh::Manager.launch
```
  
Then execute
```bash
$> rackup
```
in the command line to start the server.

More instructions to follow.

  [1]: http://travis-ci.org/jimjh/ruhoh-manager
  [2]: https://codeclimate.com/github/jimjh/ruhoh-manager

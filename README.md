# puma socket leak application

Puma 2.0.1 right now have a socket leak problem.
It leaks socket/fd when it's restarted.

This application is a minimum set to show how
puma leaks its sockets on restart.
Same thing should happen on file descriptors.


## How to use this application

First, this program tries to connect to a MySQL server, so
please get one or some.
Write the MySQL connection information to config.ru, such like

    CONN = {
      :host = "localhost",
      :user = "user",
      :password = "password"
    }

and run:

    $ bundle install --path=.bundle/gems --binstubs=.bundle/bin

don't forget the binstubs option.

and then run puma by:

    $ bundle exec puma

or:

    $ bundle exec puma --daemon

Access `http://localhost:9292/` to see how many sockets are opened.
Access `http://localhost:9292/reload` to send USR2 to the process.


## What this application does

When starting, the application simply opens a MySQL connection by using `mysql2` gem.
Connection is kept in a class variable.

By accessing the server, you will see the sockets opened.
This information is taken from /proc filesystem, so this application only works on
Linux with procfs mounted (or those compatible to it).

Accessing to `/reload` will send `-USR2` to the server process itself.
You will be seeing the sockets increasing than before.


## Why it leaks

Puma server implements `restart` by `exec`-ing its process into a new one.
On `exec`, file descriptors are not wasted by default.
If you want it wasted, you must set `close-on-exec` on the file descriptor.

Ruby provides us an easy way to close the file descriptors (those higher than 0,1,2) when exec-ing,
by giving an option `:close_others` to `Kernel#exec`.

In ruby 2.0.0 or higher, file descriptors are created with `close-on-exec` flag by default.
Therefore, this problem doesn't appear on ruby 2.0.0 or later.


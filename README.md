newblog
=======

newblog is my second attempt at a fully client-side generated blog, this time
using [nanoc][] and [Bootstrap][] instead of [jekyll][] and a homegrown CSS
template.


Current status
--------------

I neglected to update this section for far too long. Content management works,
CSS generation has been removed because stock Bootstrap with a few overrides
in a local CSS are more than enough.

The kramdown-based rendering engine and associated plugins are gone, I
switched to GitHub's own [redcarpet](https://github.com/vmg/redcarpet).
Couldn't be happier about the switch, as I'm now free to relicense the
infrastructure under a less asinine license.

Almost everything in the `content` directory is strictly personal (even though
CC-licensed) - if you intend to fork this repo *please* edit all pages,
footers and the like and remove all posts.


Requirements
------------

### Client-side

* a recent version of Ruby with RubyGems ([rbenv][] is your friend)
* [Bundler](http://gembundler.com)
* [Twitter RECESS](https://twitter.github.io/recess/) and associated
  dependencies (that means node.js et al.)
* a text editor (other than Emacs)
* a shell

Writing skills are entirely optional ;-)

#### Note for RVM users

RVM is absolutely **NOT** supported anymore and you shouldn't use it.

### Ruby setup

The absolute minimum supported version of Ruby is the MRI 1.9.3 interpreter.
It may work with other versions or interpreters, but YMMV.

Issues with non-MRI interpreters will be summarily closed as `wontfix`.

Since I'm not using RVM anymore (and you shouldn't too), you need to install
the gems locally using `bundle install --path vendor/bundle`. Every command
_must_ be prefixed by `bundle exec`.

If you have better alternatives that wouldn't trample over my rbenv shims
directory, please open an issue and let me know.

### Server-side

* anything capable of serving static files which isn't WEBrick or worse

Yep, that's it.


License
-------

All code of newblog used to be licensed under the terms of GPLv3 to avoid any
legal trouble concerning the use of kramdown's API in some files.

Since I excised kramdown from the rendering pipeline, the code is now licensed
under a saner 2-clause BSD (you can read it in `LICENSE`).

All content is licensed under [CC-BY-3.0][].


Known issues
------------

It exists: that's an issue unto itself.


[nanoc]: http://nanoc.stoneship.org/
[Bootstrap]: http://getbootstrap.com/
[jekyll]: http://jekyllrb.com/
[kramdown]: http://kramdown.rubyforge.org/
[CC-BY-3.0]: http://creativecommons.org/licenses/by/3.0/
[rbenv]: https://github.com/sstephenson/rbenv

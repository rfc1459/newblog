newblog
=======

newblog is my second attempt at a fully client-side generated blog, this time
using [nanoc][] and [Bootstrap][] instead of [jekyll][] and a homegrown CSS
template.


Current status
--------------

Right now, newblog is in its infancy with only a few modules implemented. Some
pages are already there since they're mostly static and (hopefully) they'll
never change. Most notably, it's still incapable of **rendering posts**
altogether, so you might want to sit this one out for the time being.

Also, some content is strictly related to myself - if you intend to fork this
repo *please* edit all pages, footers and the like.


Requirements
------------

### Client-side

  * a recent version of Ruby with RubyGems ([rvm](http://rvm.io) is your friend)
  * [Bundler](http://gembundler.com)
  * [UglifyJS](https://github.com/mishoo/UglifyJS)
  * a text editor
  * a shell

Writing skills are entirely optional ;-)

#### Note for RVM users

The absolute minimum supported version of RVM is 1.16.17 and you **must** have
a preinstalled MRI 1.9.3 interpreter.

If your setup meets those requirements, create a new gemset called `newblog`
with the appropriate interpreter and then issue a `bundle install` to fetch
and install the prerequisites.

### Server-side

  * anything capable of serving static files

Yep, that's it.


License
-------

All code of newblog is licensed under the terms of GPLv3. See `COPYING` for
more information.

All content is licensed under [CC-BY-3.0][].


Known issues
------------

Indeed.


[nanoc]: http://nanoc.stoneship.org/
[Bootstrap]: http://getbootstrap.com/
[jekyll]: http://jekyllrb.com/
[kramdown]: http://kramdown.rubyforge.org/
[CC-BY-3.0]: http://creativecommons.org/licenses/by/3.0/

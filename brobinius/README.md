# Brobinius

My attempts to do awkward things to Ruby via Rubinius' magic transformers feature.

* Transforms do things at compile time; they're cached in `rbc` files, so it's a little odd to debug them
* The interesting bits are in `lib/compiler/transform.rb`

See also: [list comprehensions](http://gist.github.com/236219 "gist: 236219 -  GitHub")
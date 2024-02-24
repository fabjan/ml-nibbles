structure Love = Love(Lua)
structure Nibbles = Nibbles(Love)
structure Engine = Engine(structure Lua = Lua structure Game = Nibbles)

val _ = Engine.run ()

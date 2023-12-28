datatype fill_mode = Fill | Line

fun luaFillMode Fill = Lua.fromString "fill"
  | luaFillMode Line = Lua.fromString "line"

datatype sound_type = Static | Stream

fun luaSoundType Static = Lua.fromString "static"
  | luaSoundType Stream = Lua.fromString "stream"

structure Love = struct

    fun setLoad (f : Lua.value) =
        Lua.setField (Lua.global "love", "load", f)
    fun setUpdate (f : Lua.value) =
        Lua.setField (Lua.global "love", "update", f)
    fun setDraw (f : Lua.value) =
        Lua.setField (Lua.global "love", "draw", f)

    structure Keyboard = struct
        fun isDown (key : string) =
            let
                val keyboard = Lua.field (Lua.global "love", "keyboard")
                val key = Lua.fromString key
                val res = Lua.call1 (Lua.field (keyboard, "isDown")) #[key]
            in
                Lua.checkBoolean res
            end
    end

	structure Graphics = struct
        fun setColor (r : real) (g : real) (b : real) (a : real) =
            let
                val graphics = Lua.field (Lua.global "love", "graphics")
                val r = Lua.fromReal r
                val g = Lua.fromReal g
                val b = Lua.fromReal b
                val a = Lua.fromReal a
            in
                Lua.call0 (Lua.field (graphics, "setColor")) #[r, g, b, a]
            end
		fun rectangle mode x y w h =
			let
                val graphics = Lua.field (Lua.global "love", "graphics")
                val mode = luaFillMode mode
				val x = Lua.fromInt x
				val y = Lua.fromInt y
				val w = Lua.fromInt w
				val h = Lua.fromInt h
			in
				Lua.call0 (Lua.field (graphics, "rectangle")) #[mode, x, y, w, h]
			end
		fun print (s : string) (x : int) (y : int) =
			let
                val graphics = Lua.field (Lua.global "love", "graphics")
				val s = Lua.fromString s
				val x = Lua.fromInt x
				val y = Lua.fromInt y
			in
				Lua.call0 (Lua.field (graphics, "print")) #[s, x, y]
			end
	end

    structure Audio = struct
        fun newSource (path : string) (mode : sound_type) =
            let
                val audio = Lua.field (Lua.global "love", "audio")
                val path = Lua.fromString path
                val mode = luaSoundType mode
            in
                Lua.call1 (Lua.field (audio, "newSource")) #[path, mode]
            end
        fun play (source : Lua.value) =
            Lua.call0 (Lua.field (source, "play")) #[source]
    end
end

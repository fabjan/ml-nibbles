functor Love (Lua: LUA) :> LOVE = struct
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
        datatype fill_mode = Fill | Line

        fun luaFillMode Fill = Lua.fromString "fill"
          | luaFillMode Line = Lua.fromString "line"

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
        type source = Lua.value
        datatype sound_type = Stream | Static

        fun luaSoundType Stream = Lua.fromString "stream"
          | luaSoundType Static = Lua.fromString "static"

        fun newSource (path : string) (mode : sound_type) =
            let
                val audio = Lua.field (Lua.global "love", "audio")
                val path = Lua.fromString path
                val mode = luaSoundType mode
            in
                Lua.call1 (Lua.field (audio, "newSource")) #[path, mode]
            end

        fun play (source : source) =
            Lua.call0 (Lua.field (source, "play")) #[source]
    end

    structure Math = struct
        fun random () : real =
            let
                val math = Lua.field (Lua.global "love", "math")
                val res = Lua.call1 (Lua.field (math, "random")) #[]
            in
                Lua.checkReal res
            end
    end

    structure Window = struct
        fun setTitle (title : string) =
            let
                val window = Lua.field (Lua.global "love", "window")
                val title = Lua.fromString title
            in
                Lua.call0 (Lua.field (window, "setTitle")) #[title]
            end
    end

end

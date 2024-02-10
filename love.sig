signature LOVE = sig

    structure Keyboard : sig
        val isDown : string -> bool
    end

    structure Graphics : sig
        datatype fill_mode = Fill | Line
        val setColor : real -> real -> real -> real -> unit
        val rectangle : fill_mode -> int -> int -> int -> int -> unit
        val print : string -> int -> int -> unit
    end

    structure Audio : sig
        datatype sound_type = Static | Stream
        type source
        val newSource : string -> sound_type -> source
        val play : source -> unit
    end

    structure Math : sig
        val random : unit -> real
    end

    structure Window : sig
        val setTitle : string -> unit
    end

end

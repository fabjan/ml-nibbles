functor Nibbles (Love : LOVE) : GAME =
struct

type coord = {x : int, y : int}
type color = {r : real, g : real, b : real, a : real}
datatype direction = Up | Down | Left | Right

type snake = {idle : real, cells : coord list, direction : direction, full : bool}

fun snakeSetIdle (snake : snake) (idle : real) : snake =
    {
        idle = idle,
        cells = #cells snake,
        direction = #direction snake,
        full = #full snake
    }

fun snakeSetFull (snake : snake) (full : bool): snake =
    {
        full = full,
        cells = #cells snake,
        direction = #direction snake,
        idle = #idle snake
    }

type apple = {idle : real, place : coord}

type board = {width : int, height : int}

type game = {
    alive : bool,
    board : board,
    snake : snake,
    score : real,
    apple : apple
}

type t = game

type input = {
    up : bool,
    down : bool,
    left : bool,
    right : bool
}

val tileSize = 10
val restartKey = "r"
val speedupKey = "space"

val soundPickup = Love.Audio.newSource "assets/pickup.wav" Love.Audio.Static
val soundDie = Love.Audio.newSource "assets/die.wav" Love.Audio.Static

fun snakeString (game : game) =
    "Snake: " ^ Int.toString (List.length (#cells (#snake game)))

fun scoreString (game : game) =
    "Score: " ^ Int.toString (Real.trunc (#score game))

fun random lower upper =
    let
        val r = Love.Math.random ()
    in
        Real.floor (Real.fromInt lower + r * Real.fromInt (upper - lower))
    end

fun newApple (board : board) =
    {
        idle = 0.0,
        place = {
            x = random 0 (#width board),
            y = random 0 (#height board)
        }
    }

fun newSnake (board : board) =
    {
        idle = 0.0,
        direction = Right,
        full = false,
        cells = [
            {
                x = (#width board) div 2,
                y = (#height board) div 2
            }
        ]
    }

fun init () =
    let
        val _ = Love.Window.setTitle "Nibbles"
        val board = {width = 80, height = 60}
    in
        {
            alive = true,
            board = board,
            snake = newSnake board,
            score = 0.0,
            apple = newApple board
        }
    end

fun coordDelta (direction : direction) =
    case direction of
        Up => {x = 0, y = ~1}
    |    Down => {x = 0, y = 1}
    |    Left => {x = ~1, y = 0}
    |    Right => {x = 1, y = 0}

fun growHead (snake : snake) =
    let
        val cells = #cells snake
        val head = List.hd cells
        val delta = coordDelta (#direction snake)
        val newHead = {
            x = (#x head) + (#x delta),
            y = (#y head) + (#y delta)
        }
    in
        {
            cells = newHead :: cells,
            direction = #direction snake,
            idle = #idle snake,
            full = #full snake
        }
    end

fun dragTail (snake : snake) =
    let
        val cells = #cells snake
        val tail = List.take (cells, List.length cells - 1)
    in
        {
            cells = tail,
            direction = #direction snake,
            idle = #idle snake,
            full = #full snake
        }
    end

fun moveDelay (snake : snake) =
    if Love.Keyboard.isDown speedupKey
    then 0.01
    else
        0.01 + 0.1 * Math.pow (0.9, Real.fromInt (List.length (#cells snake)))

fun moveSnake (snake : snake) : snake =
    if (#idle snake) < (moveDelay snake)
    then snake
    else
        let
            val snake = growHead snake
            val snake = snakeSetIdle snake 0.0
        in
            if #full snake
            then snakeSetFull snake false
            else dragTail snake
        end

fun changeDirection _ NONE = false
|    changeDirection Up (SOME Down) = false
|    changeDirection Down (SOME Up) = false
|    changeDirection Left (SOME Right) = false
|    changeDirection Right (SOME Left) = false
|    changeDirection _ _ = true

fun controlSnake (snake : snake) (input : direction option) =
    if (changeDirection (#direction snake) input) then
        {
            idle = #idle snake,
            cells = #cells snake,
            direction = Option.valOf input,
            full = #full snake
        }
    else
        snake

fun updateSnake (dt : real) (snake : snake) (input : direction option) =
    let
        val snake = snakeSetIdle snake (#idle snake + dt)
        val snake = controlSnake snake input
    in
        moveSnake snake
    end

fun updateApple (dt : real) (apple : apple) =
    {
        idle = #idle apple + dt,
        place = #place apple
    }

fun canEatApple (snake : snake) (apple : apple) =
    #place apple = List.hd (#cells snake)

fun collidesWithWall (snake : snake) (board : board) =
    let
        val head = List.hd (#cells snake)
        val x = #x head
        val y = #y head
        val width = #width board
        val height = #height board
    in
        x < 0 orelse width <= x orelse y < 0 orelse height <= y
    end

fun collidesWithSelf (snake : snake) =
    case #cells snake of
        [] => raise Fail "Snake has no head"
    |    head :: tail =>    List.exists (fn cell => cell = head) tail

fun gameOver (game : game) =
    {
        alive = false,
        board = #board game,
        snake = #snake game,
        score = #score game,
        apple = #apple game
    }

fun getInput () =
    let
        val up = Love.Keyboard.isDown "up"
        val down = Love.Keyboard.isDown "down"
        val left = Love.Keyboard.isDown "left"
        val right = Love.Keyboard.isDown "right"
    in
        case (up, down, left, right) of
            (true, false, false, false) => SOME Up
        |    (false, true, false, false) => SOME Down
        |    (false, false, true, false) => SOME Left
        |    (false, false, false, true) => SOME Right
        |    _ => NONE
    end

fun update (dt : real) (game : game) =
    let
        val input = getInput ()
        val snake = (updateSnake dt (#snake game) input)
        val apple = (updateApple dt (#apple game))
    in
        if not (#alive game) then
            if Love.Keyboard.isDown restartKey
            then init ()
            else game
        else if (collidesWithSelf snake) orelse (collidesWithWall snake (#board game)) then
            (
                Love.Audio.play soundDie;
                gameOver game
            )
        else if canEatApple snake apple then
            (
                Love.Audio.play soundPickup;
                {
                    snake = snakeSetFull snake true,
                    score = #score game + 100.0 - #idle apple,
                    apple = newApple (#board game),
                    board = #board game,
                    alive = #alive game
                }
            )
        else
            {
                snake = snake,
                apple = apple,
                score = #score game,
                board = #board game,
                alive = #alive game
            }
    end

fun drawBoard (board : board) =
    let
        val width = #width board * tileSize
        val height = #height board * tileSize
    in
        (
            Love.Graphics.setColor 0.1 0.1 0.1 1.0;
            Love.Graphics.rectangle Love.Graphics.Fill 0 0 width height
        )
    end

fun fillCell (color : color) (coord : coord) =
    let
        val x = #x coord * tileSize
        val y = #y coord * tileSize
    in
        (
            Love.Graphics.setColor (#r color) (#g color) (#b color) (#a color);
            Love.Graphics.rectangle Love.Graphics.Fill x y tileSize tileSize
        )
    end

val red = {r = 1.0, g = 0.0, b = 0.0, a = 1.0}
val green = {r = 0.0, g = 1.0, b = 0.0, a = 1.0}
val darkGreen = {r = 0.0, g = 0.5, b = 0.0, a = 1.0}

fun drawApple (apple : apple) =
    fillCell red (#place apple)

fun drawSnake (game : game) =
    let
        val snake = #snake game
        val color = if #alive game then green else darkGreen
    in
        List.foldl
            (fn (cell, _) => fillCell color cell)
            ()
            (#cells snake)
    end

fun drawGameOver (game : game) =
    if #alive game then
        ()
    else
        (
            Love.Graphics.setColor 1.0 0.0 0.0 1.0;
            Love.Graphics.print "Game Over" 400 300;
            Love.Graphics.print ("Press '" ^ restartKey ^ "' to restart") 400 320;
            ()
        )

fun draw (game : game) =
    (
        drawBoard (#board game);
        drawSnake game;
        drawApple (#apple game);
        Love.Graphics.setColor 1.0 1.0 1.0 1.0;
        Love.Graphics.print (scoreString game) 20 20;
        Love.Graphics.print (snakeString game) 20 40;
        drawGameOver game;
        ()
    )

end

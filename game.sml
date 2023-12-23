type coord = {x : int, y : int}
type color = {r : real, g : real, b : real, a : real}
datatype direction = Up | Down | Left | Right

type snake = {idle : real, cells : coord list, direction : direction, full : bool}

type apple = {idle : real, place : coord}

type board = {width : int, height : int}

type game = {
	board : board,
	snake : snake,
	score : real,
	apple : apple
}

type input = {
	up : bool,
	down : bool,
	left : bool,
	right : bool
}

val tileSize = 10

fun appleString (apple : apple) =
	"Apple: " ^ Int.toString (#x (#place apple)) ^ ", " ^ Int.toString (#y (#place apple))

fun snakeString (snake : snake) =
	"Snake: " ^ Int.toString (#x (List.hd (#cells snake))) ^ ", " ^ Int.toString (#y (List.hd (#cells snake)))

fun scoreString (score : real) =
	"Score: " ^ Real.toString score

fun random lower upper =
	let
		val lower = Lua.fromInt lower
		val upper = Lua.fromInt upper
		val res = Lua.call Lua.Lib.math.random #[lower, upper]
	in
		Lua.checkInt (Vector.sub (res, 0))
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
		idle = 0,
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
		val board = {width = 80, height = 60}
		val snake = newSnake board
		val game = {board = board, snake = snake, score = 0.0, apple = newApple board}
	in
		game
	end

fun coordDelta (direction : direction) =
	case direction of
		Up => {x = 0, y = ~1}
	|	Down => {x = 0, y = 1}
	|	Left => {x = ~1, y = 0}
	|	Right => {x = 1, y = 0}

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
		{snake where cells = newHead :: cells}
	end

fun dragTail (snake : snake) =
	let
		val cells = #cells snake
		val tail = List.take (cells, List.length cells - 1)
	in
		{snake where cells = tail}
	end

fun moveSnake (snake : snake) =
	if (#idle snake) < 0.1
	then snake
	else
		let
			val snake = growHead snake
			val snake = {snake where idle = 0.0}
		in
			if #full snake
			then {snake where full = false}
			else dragTail snake
		end

fun getInput () =
	let
		val up = Love.Keyboard.isDown "up"
		val down = Love.Keyboard.isDown "down"
		val left = Love.Keyboard.isDown "left"
		val right = Love.Keyboard.isDown "right"
	in
		case (up, down, left, right) of
			(true, false, false, false) => SOME Up
		|	(false, true, false, false) => SOME Down
		|	(false, false, true, false) => SOME Left
		|	(false, false, false, true) => SOME Right
		|	_ => NONE
	end

fun controlSnake (snake : snake) =
	case (getInput (), #direction snake) of
		(NONE, _) => snake
	|	(SOME Up, Down) => snake
	|	(SOME Down, Up) => snake
	|	(SOME Left, Right) => snake
	|	(SOME Right, Left) => snake
	|	(SOME dir, _) => {snake where direction = dir}

fun updateSnake (dt : real) (snake : snake) =
	let
		val idle = #idle snake + dt
		val snake = {snake where idle = idle}
		val snake = controlSnake snake
	in
		moveSnake snake
	end

fun updateApple (dt : real) (apple : apple) =
	{apple where idle = #idle apple + dt}

fun canEatApple (snake : snake) (apple : apple) =
	#place apple = List.hd (#cells snake)

fun update (dt : real) (game : game) =
	let
		val snake = (updateSnake dt (#snake game))
		val apple = (updateApple dt (#apple game))
	in
		if canEatApple snake apple
		then
			let
				val score = #score game + 100.0 - #idle apple
				val apple = newApple (#board game)
				val snake = {snake where full = true}
			in
				{game where snake = snake, score = score, apple = apple}
			end
		else
			{game where snake = snake, apple = apple}
	end

fun drawBoard (board : board) =
	let
		val width = #width board * tileSize
		val height = #height board * tileSize
	in
		(
			Love.Graphics.setColor 0.1 0.1 0.1 1.0;
			Love.Graphics.rectangle Fill 0 0 width height
		)
	end

fun fillCell (color : color) (coord : coord) =
	let
		val x = #x coord * tileSize
		val y = #y coord * tileSize
	in
		(
			Love.Graphics.setColor (#r color) (#g color) (#b color) (#a color);
			Love.Graphics.rectangle Fill x y tileSize tileSize
		)
	end

val red = {r = 1.0, g = 0.0, b = 0.0, a = 1.0}
val green = {r = 0.0, g = 1.0, b = 0.0, a = 1.0}

fun drawApple (apple : apple) =
	fillCell red (#place apple)

fun drawSnake (snake : snake) =
	List.foldl
		(fn (cell, _) => fillCell green cell)
		#[]
		(#cells snake)

fun draw (game : game) =
	(
		drawBoard (#board game);
		drawSnake (#snake game);
		drawApple (#apple game);
		Love.Graphics.setColor 1.0 1.0 1.0 1.0;
		Love.Graphics.print (scoreString (#score game)) 20 20;
		()
	)

type player = {x : real, y : real}

type game = {score : real, player : player}

fun moveLeft dx (player : player) = {player where x = (#x player) - dx}
fun moveRight dx (player : player) = {player where x = (#x player) + dx}

fun init () = {
	score = 0,
	player = {x = 0, y = 0}
}

fun updatePlayer (dt : real) (player : player) =
	let
		val speed = 100.0
		val left = Love.Keyboard.isDown "left"
		val right = Love.Keyboard.isDown "right"
		val dx = speed * dt
	in
		case (left, right) of
			(true, false) => moveLeft dx player
		|	(false, true) => moveRight dx player
		|	_ => player
	end

fun update (dt : real) (game : game) =
	let
		val game = {game where player = updatePlayer dt (#player game)}
		val game = {game where score = (#score game) + dt}
	in
		game
	end

fun draw (game : game) =
	let
		val hello = "Hello, World! " ^ Real.toString (#score game)
		val player = #player game
		val px = Real.floor (#x player)
		val py = Real.floor (#y player)
	in
		(
			Love.Graphics.print hello 400 300;
			Love.Graphics.rectangle Fill px py 10 10
		)
	end

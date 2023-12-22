type player = {x : real, y : real}

type game = {score : real, player : player}

fun moveLeft dx (player : player) = {player where x = (#x player) - dx}
fun moveRight dx (player : player) = {player where x = (#x player) + dx}

fun init () = {
	score = 0,
	player = {x = 0, y = 0}
}

fun update (dt : real) (game : game) =
	let
		val game = {game where player = moveRight (dt * 100.0) (#player game)}
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

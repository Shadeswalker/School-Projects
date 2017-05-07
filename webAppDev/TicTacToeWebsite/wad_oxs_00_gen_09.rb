# Ruby code file - All your code should be located between the comments provided.

# Add any additional gems and global variables here
require 'sinatra'		# remove '#' character to run sinatra wen server

# Main class module
module OXs_Game
	# Input and output constants processed by subprocesses. MUST NOT change.
	NOUGHT = 0
	CROSS = 1

	class Game
		attr_reader :matrix, :input, :output, :player1, :player2, :winner
		attr_writer :matrix, :input, :output, :player1, :player2, :winner
		
		def initialize(input, output)
			@input = input
			@output = output
		end
		
		# Any code/methods aimed at passing the RSpect tests should be added below.
		def start
			@output.puts "Welcome to Noughts and Crosses!"
			@output.puts "Created by:#{created_by}"
			@output.puts "Starting game..."
			@output.puts "Player 1: 0 and Player 2: 1"
		end
		
		def created_by
			myname = "Arjun B. Gupta"
			return myname
		end
		
		def student_id
			student_id = 51443400
			return student_id
		end
		
		def setplayer1
			@player1 = 0
		end
		
		def setplayer2
			@player2 = 1
		end
		
		def clearmatrix
			@matrix = ["_", "_", "_", "_", "_", "_", "_", "_", "_"]
		end
		
		def getmatrixvalue(value)
			if @matrix[value] == "_"
				return @matrix[value]
			else
				return false
			end
		end
		
		def setmatrixvalue(i, v)
			if @matrix[i] == "_" then @matrix[i] = v
			end
		end
		
		def displaykey(matrix)
			matrix = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
			@output.puts ("Table key:\n|#{matrix[0]}|#{matrix[1]}|#{matrix[2]}|\n|#{matrix[3]}|#{matrix[4]}|#{matrix[5]}|\n|#{matrix[6]}|#{matrix[7]}|#{matrix[8]}|\n")
		end
		
		def displaymatrix
			@output.puts ("Table status:\n|#{matrix[0]}|#{matrix[1]}|#{matrix[2]}|\n|#{matrix[3]}|#{matrix[4]}|#{matrix[5]}|\n|#{matrix[6]}|#{matrix[7]}|#{matrix[8]}|\n")
		end
		
		def finish
			@output.puts ("Finishing game...")
		end
		
		def displaymenu
			@output.puts ("Menu: (1)Start | (2)New | (9)Exit\n")
			userinput = @input.gets.chomp.to_i
			return userinput
		end
		
		def checkwinner
			@winner = nil
			if matrix[0] == "0" && matrix[1] == "0" && matrix[2] == "0" then
				@winner = 1
			elsif matrix[3] == "0" && matrix[4] == "0" && matrix[5] == "0" then
				@winner = 1
			elsif matrix[6] == "0" && matrix[7] == "0" && matrix[8] == "0" then
				@winner = 1
			elsif matrix[0] == "0" && matrix[3] == "0" && matrix[6] == "0" then
				@winner = 1
			elsif matrix[1] == "0" && matrix[4] == "0" && matrix[7] == "0" then
				@winner = 1
			elsif matrix[2] == "0" && matrix[5] == "0" && matrix[8] == "0" then
				@winner = 1
			elsif matrix[0] == "0" && matrix[4] == "0" && matrix[8] == "0" then
				@winner = 1
			elsif matrix[2] == "0" && matrix[4] == "0" && matrix[6] == "0" then
				@winner = 1
			elsif matrix[0] == "1" && matrix[1] == "1" && matrix[2] == "1" then
				@winner = 2
			elsif matrix[3] == "1" && matrix[4] == "1" && matrix[5] == "1" then
				@winner = 2
			elsif matrix[6] == "1" && matrix[7] == "1" && matrix[8] == "1" then
				@winner = 2
			elsif matrix[0] == "1" && matrix[3] == "1" && matrix[6] == "1" then
				@winner = 2
			elsif matrix[1] == "1" && matrix[4] == "1" && matrix[7] == "1" then
				@winner = 2
			elsif matrix[2] == "1" && matrix[5] == "1" && matrix[8] == "1" then
				@winner = 2
			elsif matrix[0] == "1" && matrix[4] == "1" && matrix[8] == "1" then
				@winner = 2
			elsif matrix[2] == "1" && matrix[4] == "1" && matrix[6] == "1" then
				@winner = 2
			else
				@winner = nil
			end
		end

		
		# Any code/methods aimed at passing the RSpect tests should be added above.

	end
end


# Main program
module OXs_Game
	@input = STDIN
	@output = STDOUT
	g = Game.new(@input, @output)
	matrixkey = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
	matrix = ["_", "_", "_", "_", "_", "_", "_", "_", "_"]
	playing = true
	input = ""
	option = 0
	turn = 0
		
	# Any code added to output the activity messages to the command line window should be added below.
	g.start
	g.displaykey(matrix)
	g.setplayer1
	g.setplayer2
	g.clearmatrix
	while true #looping the game so that stopping it is voluntary
		case g.displaymenu
			when 1
				g.clearmatrix
				playerturn = 0
				winner = nil
				while winner == nil #looping so that the game will not stop until a player wins
					if playerturn % 2 == 0
						playing = true
						@output.puts("Player 1 turn's to play. Select a case from the table key.")
						while playing #loop used so that in case of wrong input, the player keeps his turn until entering a correct key.
							key = @input.gets.chomp.to_i - 1
							if key >= 0 and key <= 8 and g.getmatrixvalue(key) == "_"
								g.setmatrixvalue(key, "0")
								g.displaymatrix
								playerturn += 1
								playing = false
								g.checkwinner
								if g.checkwinner != nil
									@output.puts("Player 1 wins!")
									winner = 1
								elsif playerturn == 9
									@output.puts("Game Draw!")
									winner = 2
								end
							else
								@output.puts("The case you entered has already been played or does not exist. Player 1 play again.")
							end
						end
					else
						playing = true
						@output.puts("Player 2 turn's to play. Select a case from the table key.")
						while playing
							key = @input.gets.chomp.to_i - 1
							if key >= 0 and key <= 8 and g.getmatrixvalue(key) == "_"
								g.setmatrixvalue(key, "1")
								g.displaymatrix
								playerturn += 1
								playing = false
								g.checkwinner
								if g.checkwinner != nil
									@output.puts("Player 2 wins!")
									winner = 1
								end
							else
								@output.puts("The case you entered has already been played or does not exist. Player 2 play again.")
							end
						end
					end
				end
			
			when 2
				g.clearmatrix
				g.displaymatrix
			when 9
				g.finish
				break
				
			else
				@output.puts("Unknown command. Chose 1, 2 or 9")
		end
	
	end
	# Any code added to output the activity messages to the command line window should be added above.

end
# End modules

# Sinatra routes

	# Any code added to output the activity messages to a browser should be added below.

helpers do
	def checkwinner
		@winner = nil
		if $matrix[0] == "X" && $matrix[1] == "X" && $matrix[2] == "X" then
			@winner = 1
		elsif $matrix[3] == "X" && $matrix[4] == "X" && $matrix[5] == "X" then
			@winner = 1
		elsif $matrix[6] == "X" && $matrix[7] == "X" && $matrix[8] == "X" then
			@winner = 1
		elsif $matrix[0] == "X" && $matrix[3] == "X" && $matrix[6] == "X" then
			@winner = 1
		elsif $matrix[1] == "X" && $matrix[4] == "X" && $matrix[7] == "X" then
			@winner = 1
		elsif $matrix[2] == "X" && $matrix[5] == "X" && $matrix[8] == "X" then
			@winner = 1
		elsif $matrix[0] == "X" && $matrix[4] == "X" && $matrix[8] == "X" then
			@winner = 1
		elsif $matrix[2] == "X" && $matrix[4] == "X" && $matrix[6] == "X" then
			@winner = 1
		elsif $matrix[0] == "O" && $matrix[1] == "O" && $matrix[2] == "O" then
			@winner = 2
		elsif $matrix[3] == "O" && $matrix[4] == "O" && $matrix[5] == "O" then
			@winner = 2
		elsif $matrix[6] == "O" && $matrix[7] == "O" && $matrix[8] == "O" then
			@winner = 2
		elsif $matrix[0] == "O" && $matrix[3] == "O" && $matrix[6] == "O" then
			@winner = 2
		elsif $matrix[1] == "O" && $matrix[4] == "O" && $matrix[7] == "O" then
			@winner = 2
		elsif $matrix[2] == "O" && $matrix[5] == "O" && $matrix[8] == "O" then
			@winner = 2
		elsif $matrix[0] == "O" && $matrix[4] == "O" && $matrix[8] == "O" then
			@winner = 2
		elsif $matrix[2] == "O" && $matrix[4] == "O" && $matrix[6] == "O" then
			@winner = 2
		else
			@winner = nil
		end
	end
end

$matrix = ["_", "_", "_", "_", "_", "_", "_", "_", "_"]
$playerturn = 0
$wins1 = 0
$wins2 = 0
$games = 0
$draws= 0

get '/' do
	erb :home
end

get '/start' do
	erb :start
end

post '/start' do
	if $playerturn%2 == 0
		key =  params[:case].to_i
		$matrix[key] = "X"
		$playerturn += 1
		checkwinner
		if @winner != nil
			$wins1 += 1
			redirect '/winner'
		elsif $playerturn == 9
			$draws += 1
			redirect '/draw'
		else
			redirect '/start'
		end
	else
		key = params[:case].to_i
		$matrix[key] = "O"
		$playerturn += 1
		checkwinner
		if @winner != nil
			$wins2 += 1
			redirect '/winner'
		else
			redirect '/start'
		end
	end
end

get'/about' do
	erb :about
end

get '/newgame' do
	$matrix = ["_", "_", "_", "_", "_", "_", "_", "_", "_"]
	$playerturn = 0
	@winner = nil
	$games += 1
	redirect '/start'
end

get '/winner' do
	erb :winner
end

get '/draw' do
	erb :draw
end

get '/notfound' do
	erb :notfound
end

not_found do  
	status 404  
	redirect '/notfound'  
end  


	# Any code added to output the activity messages to a browser should be added above.

# End program
# Ruby assignment
# Change the following tests with your own name and student ID.
# NB. Failure to do so will result in marks being deducted.
# IMPORTANT: Ensure you save the file after making the changes. 
# DO notchange the names of the files. Just ensure you backup the files offen.

# The file where you are to write code to pass the tests must be present in the same folder.
# See http://rspec.codeschool.com/levels/1 for help about RSpec
require "#{File.dirname(__FILE__)}/wad_oxs_00_gen_09"

# predefined method - NOT to be removed
def check_winner
	@game.winner = nil
#	puts "check_winner: #{@game.matrix}"
	if @game.matrix[0] == "0" && @game.matrix[1] == "0" && @game.matrix[2] == "0" then
		@game.winner = 1
	elsif @game.matrix[3] == "0" && @game.matrix[4] == "0" && @game.matrix[5] == "0" then
		@game.winner = 1
	elsif @game.matrix[6] == "0" && @game.matrix[7] == "0" && @game.matrix[8] == "0" then
		@game.winner = 1
	elsif @game.matrix[0] == "0" && @game.matrix[3] == "0" && @game.matrix[6] == "0" then
		@game.winner = 1
	elsif @game.matrix[1] == "0" && @game.matrix[4] == "0" && @game.matrix[7] == "0" then
		@game.winner = 1
	elsif @game.matrix[2] == "0" && @game.matrix[5] == "0" && @game.matrix[8] == "0" then
		@game.winner = 1
	elsif @game.matrix[0] == "0" && @game.matrix[4] == "0" && @game.matrix[8] == "0" then
		@game.winner = 1
	elsif @game.matrix[2] == "0" && @game.matrix[4] == "0" && @game.matrix[6] == "0" then
		@game.winner = 1
	elsif @game.matrix[0] == "1" && @game.matrix[1] == "1" && @game.matrix[2] == "1" then
		@game.winner = 2
	elsif @game.matrix[3] == "1" && @game.matrix[4] == "1" && @game.matrix[5] == "1" then
		@game.winner = 2
	elsif @game.matrix[6] == "1" && @game.matrix[7] == "1" && @game.matrix[8] == "1" then
		@game.winner = 2
	elsif @game.matrix[0] == "1" && @game.matrix[3] == "1" && @game.matrix[6] == "1" then
		@game.winner = 2
	elsif @game.matrix[1] == "1" && @game.matrix[4] == "1" && @game.matrix[7] == "1" then
		@game.winner = 2
	elsif @game.matrix[2] == "1" && @game.matrix[5] == "1" && @game.matrix[8] == "1" then
		@game.winner = 2
	elsif @game.matrix[0] == "1" && @game.matrix[4] == "1" && @game.matrix[8] == "1" then
		@game.winner = 2
	elsif @game.matrix[2] == "1" && @game.matrix[4] == "1" && @game.matrix[6] == "1" then
		@game.winner = 2
	else
		@game.winner = nil
	end
#	puts "#{@game.winner}"
	@game.winner
end

module OXs_Game
	# RSpec Tests 
	describe Game do
		describe "#start the game" do
			before(:each) do
				@input = double('input').as_null_object
				@output = double('output').as_null_object
				@game = Game.new(@input, @output)
			end
			it "should send a welcome message" do
				@output.should_receive(:puts).with('Welcome to Noughts and Crosses!')
				@game.start
			end
			it "should contain a method created_by which returns the students name" do
				myname = @game.created_by
				myname.should == "Arjun B. Gupta"	# -----Change text to your own name-----
			end
			it "should contain a method student_id which returns the students ID number" do
				studentid = @game.student_id
				studentid.should == 51443400		# -----Change ID to your own student ID number-----
			end
			it "should send a created by message" do
				@output.should_receive(:puts).with("Created by:#{@game.created_by}")
				@game.start
			end
			it "should send a start message" do
				@output.should_receive(:puts).with('Starting game...')
				@game.start			
			end
			it "should prompt player 1" do
				@output.should_receive(:puts).with("Player 1: 0 and Player 2: 1")
				@game.start
			end
			it "should set status of the player 1 to 0 - noughts" do
				@game.setplayer1
				@game.player1.should eql 0
			end
			it "should set status of the player 2 to 1 - crosses" do
				@game.setplayer2
				@game.player2.should eql 1
			end
			it "should clear matrix" do
				matrix = ["_", "_", "_", "_", "_", "_", "_", "_", "_"]
				@game.clearmatrix
				@game.matrix.should eql matrix
			end
			it "should get a cell value" do
				@game.clearmatrix
				value = @game.getmatrixvalue(0)
				value.should == "_"
			end
			it "should set a cell value to '0'" do
				i = 1
				v = "0"
				@game.clearmatrix
				@game.setmatrixvalue(i,  v)
				@game.matrix[i].should == v				
			end
			it "should display matrix key as a table" do
				matrix = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
				@output.should_receive(:puts).with("Table key:\n|#{matrix[0]}|#{matrix[1]}|#{matrix[2]}|\n|#{matrix[3]}|#{matrix[4]}|#{matrix[5]}|\n|#{matrix[6]}|#{matrix[7]}|#{matrix[8]}|\n")
				@game.displaykey(matrix)				
			end
			it "should display matrix as a table" do
				matrix = ["_", "_", "_", "_", "_", "_", "_", "_", "_"]
				@game.clearmatrix
				@output.should_receive(:puts).with("Table status:\n|#{matrix[0]}|#{matrix[1]}|#{matrix[2]}|\n|#{matrix[3]}|#{matrix[4]}|#{matrix[5]}|\n|#{matrix[6]}|#{matrix[7]}|#{matrix[8]}|\n")
				@game.displaymatrix
			end
			it "should send a finish message" do
				@output.should_receive(:puts).with('Finishing game...')
				@game.finish			
			end
			it "should display menu" do
				@output.should_receive(:puts).with("Menu: (1)Start | (2)New | (9)Exit\n")
				@game.displaymenu
			end
			it "should check for a winner with top row" do
				@game.winner = nil
				@game.clearmatrix
				@game.setmatrixvalue(0,  "0")
				@game.setmatrixvalue(1,  "0")
				@game.setmatrixvalue(2,  "0")
				@game.checkwinner.should == check_winner && @game.winner.should_not == nil
			end
			it "should check for player 1 winner with middle row" do
				@game.winner = nil
				@game.clearmatrix
				@game.setmatrixvalue(3,  "0")
				@game.setmatrixvalue(4,  "0")
				@game.setmatrixvalue(5,  "0")
				@game.checkwinner.should == check_winner && @game.winner.should_not == nil
			end
			it "should check for player 1 winner with bottom row" do
				@game.winner = nil
				@game.clearmatrix
				@game.setmatrixvalue(6,  "0")
				@game.setmatrixvalue(7,  "0")
				@game.setmatrixvalue(8,  "0")
				@game.checkwinner.should == check_winner && @game.winner.should_not == nil
			end
			it "should check for player 1 winner with left column" do
				@game.winner = nil
				@game.clearmatrix
				@game.setmatrixvalue(0,  "0")
				@game.setmatrixvalue(3,  "0")
				@game.setmatrixvalue(6,  "0")
				@game.checkwinner.should == check_winner && @game.winner.should_not == nil
			end
			it "should check for player 1 winner with middle column" do
				@game.winner = nil
				@game.clearmatrix
				@game.setmatrixvalue(1,  "0")
				@game.setmatrixvalue(4,  "0")
				@game.setmatrixvalue(7,  "0")
				@game.checkwinner.should == check_winner && @game.winner.should_not == nil
			end
			it "should check for player 1 winner with right column" do
				@game.winner = nil
				@game.clearmatrix
				@game.setmatrixvalue(2,  "0")
				@game.setmatrixvalue(5,  "0")
				@game.setmatrixvalue(8,  "0")
				@game.checkwinner.should == check_winner && @game.winner.should_not == nil
			end
			it "should check for player 1 winner with down diagonal" do
				@game.winner = nil
				@game.clearmatrix
				@game.setmatrixvalue(0,  "0")
				@game.setmatrixvalue(4,  "0")
				@game.setmatrixvalue(8,  "0")
				@game.checkwinner.should == check_winner && @game.winner.should_not == nil
			end
			it "should check for player 1 winner with up diagonal" do
				@game.winner = nil
				@game.clearmatrix
				@game.setmatrixvalue(2,  "0")
				@game.setmatrixvalue(4,  "0")
				@game.setmatrixvalue(6,  "0")
				@game.checkwinner.should == check_winner && @game.winner.should_not == nil
			end
			it "should check for player 2 winner with top row" do
				@game.winner = nil
				@game.clearmatrix
				@game.setmatrixvalue(0,  "1")
				@game.setmatrixvalue(1,  "1")
				@game.setmatrixvalue(2,  "1")
				@game.checkwinner.should == check_winner && @game.winner.should_not == nil
			end
			it "should check for player 2 winner with middle row" do
				@game.winner = nil
				@game.clearmatrix
				@game.setmatrixvalue(3,  "1")
				@game.setmatrixvalue(4,  "1")
				@game.setmatrixvalue(5,  "1")
				@game.checkwinner.should == check_winner && @game.winner.should_not == nil
			end
			it "should check for player 2 winner with bottom row" do
				@game.winner = nil
				@game.clearmatrix
				@game.setmatrixvalue(6,  "1")
				@game.setmatrixvalue(7,  "1")
				@game.setmatrixvalue(8,  "1")
				@game.checkwinner.should == check_winner && @game.winner.should_not == nil
			end
			it "should check for player 2 winner with left column" do
				@game.winner = nil
				@game.clearmatrix
				@game.setmatrixvalue(0,  "1")
				@game.setmatrixvalue(3,  "1")
				@game.setmatrixvalue(6,  "1")
				@game.checkwinner.should == check_winner && @game.winner.should_not == nil
			end
			it "should check for player 2 winner with middle column" do
				@game.winner = nil
				@game.clearmatrix
				@game.setmatrixvalue(1,  "1")
				@game.setmatrixvalue(4,  "1")
				@game.setmatrixvalue(7,  "1")
				@game.checkwinner.should == check_winner && @game.winner.should_not == nil
			end
			it "should check for player 2 winner with right column" do
				@game.winner = nil
				@game.clearmatrix
				@game.setmatrixvalue(2,  "1")
				@game.setmatrixvalue(5,  "1")
				@game.setmatrixvalue(8,  "1")
				@game.checkwinner.should == check_winner && @game.winner.should_not == nil
			end
			it "should check for player 2 winner with down diagonal" do
				@game.winner = nil
				@game.clearmatrix
				@game.setmatrixvalue(0,  "1")
				@game.setmatrixvalue(4,  "1")
				@game.setmatrixvalue(8,  "1")
				@game.checkwinner.should == check_winner && @game.winner.should_not == nil
			end
			it "should check for player 2 winner with up diagonal" do
				@game.winner = nil
				@game.clearmatrix
				@game.setmatrixvalue(2,  "1")
				@game.setmatrixvalue(4,  "1")
				@game.setmatrixvalue(6,  "1")
				@game.checkwinner.should == check_winner && @game.winner.should_not == nil
			end
			it "should only overwrite an empty square" do
				i = 1
				@game.clearmatrix
				@game.setmatrixvalue(i,  "0")
				existing = @game.matrix[i]
				@game.setmatrixvalue(i,  "1")
				@game.matrix[i].should == existing	 || existing.should == "_"					
			end
		end
	end
end
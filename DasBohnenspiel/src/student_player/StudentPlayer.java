package student_player;

import java.util.ArrayList;

import bohnenspiel.BohnenspielBoardState;
import bohnenspiel.BohnenspielMove;
import bohnenspiel.BohnenspielPlayer;
import student_player.mytools.MyTools;

/** A Hus player submitted by a student. */
public class StudentPlayer extends BohnenspielPlayer {

    /** You must modify this constructor to return your student number.
     * This is important, because this is what the code that runs the
     * competition uses to associate you with your agent.
     * The constructor should do nothing else. */
    public StudentPlayer() { super("260623737"); }
    
    /** This is the primary method that you need to implement.
     * The ``board_state`` object contains the current state of the game,
     * which your agent can use to make decisions. See the class
	 * bohnenspiel.RandomPlayer for another example agent. */
    public BohnenspielMove chooseMove(BohnenspielBoardState board_state)
    {
    	//During first turn, we have more computation time to do some setup
    	if (board_state.getTurnNumber() == 0) {
    		long startTime = System.nanoTime();
            
            long endTime = System.nanoTime();
            long duration = (endTime - startTime)/1000000;
    	}
    	
    	// Get the current player's legal moves in the current board state
        ArrayList<BohnenspielMove> moves = board_state.getLegalMoves();
        int score = 0;
        int bestScore = Integer.MIN_VALUE;
        BohnenspielMove bestMove = moves.get(0);
        
        //try all legal moves available
        for (BohnenspielMove move : moves){
    		// Clone board to test hypothetical cases
            BohnenspielBoardState cloned_board_state = (BohnenspielBoardState) board_state.clone();
    		cloned_board_state.move(move);
    		//check if it's player's turn in which case we maximize utility at this level
    		score = miniMax(cloned_board_state, 7, false);
    		if (score > bestScore) {
    			bestScore = score;
    			bestMove = move;
    		}
        }
    	return bestMove;
    }
    
    /** This method implements the minimax algorithm.
     *  @param board_state contains the current state of the game
     *  @param depth is the max tree depth to which we allow the algorithm to run
     *  @param max - if set to true, will maximize utility. Otherwise minimizes.
     */
    public int miniMax(BohnenspielBoardState board_state, int depth, boolean max)
    {
        //if we reached a leaf or the max depth limit
        if (board_state.gameOver() || depth == 0) {
        	 return evaluateScore(board_state); //get heuristic score
        } else {
        	// Get the current player's legal moves in the current board state
            ArrayList<BohnenspielMove> moves = board_state.getLegalMoves();
            
            int score = 0;
            int bestScore = max ? Integer.MIN_VALUE : Integer.MAX_VALUE;
            
        	//try all legal moves available
        	for (BohnenspielMove move : moves){
        		// Clone board to test hypothetical cases
                BohnenspielBoardState cloned_board_state = (BohnenspielBoardState) board_state.clone();
        		cloned_board_state.move(move);
        		//check if it's player's turn in which case we maximize utility at this level
        		if (max) {
        			score = miniMax(cloned_board_state, depth-1, false);
        			if (score > bestScore) {
        				bestScore = score;
        			}
        		//opponents turn, minimize utility
        		} else {
        			score = miniMax(cloned_board_state, depth-1, true);
        			if (score < bestScore) {
        				bestScore = score;
        			}
        		}
        	}
        	return bestScore;
        }
    }
    
    
    /**
     * This method evaluates a heuristic score for the player.
     * @param board_state : state of board we want to evaluate
     * @return +1 for every seed captured by player, -1 for every seed captured by opponent<br>
     *         +1 for every seed in player's pits, -1 for every seed in opponent's pit
     */
	private int evaluateScore(BohnenspielBoardState board_state) {
		// Get the contents of the pits so we can use it to make decisions.
        int[][] pits = board_state.getPits();

        // Use ``player_id`` and ``opponent_id`` to get my pits and opponent pits.
        int[] my_pits = pits[player_id];
        int[] op_pits = pits[opponent_id];
		int heuristic = board_state.getScore(player_id) - board_state.getScore(opponent_id);
		
		for (int i=0; i<6; i++){
			heuristic += my_pits[i] - op_pits[i];
		}
		return heuristic;
	}
}
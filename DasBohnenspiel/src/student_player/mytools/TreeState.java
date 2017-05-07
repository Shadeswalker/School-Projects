package student_player.mytools;

import bohnenspiel.BohnenspielBoardState;

/**
 * A state of the game with a field heuristic that stores the heuristic score
 * and depth that stores the depth of the state
 */
public class TreeState {
	
	int depth;
	int heuristic;
	BohnenspielBoardState board_state;
	
	public TreeState(int depth, int heuristic, BohnenspielBoardState board_state) {
		this.depth = depth;
		this.heuristic = heuristic;
		this.board_state = board_state;
	}
	
	
}

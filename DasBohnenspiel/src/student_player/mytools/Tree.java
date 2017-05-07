package student_player.mytools;

import java.util.ArrayList;
import java.util.List;
import bohnenspiel.BohnenspielBoardState;
import bohnenspiel.BohnenspielMove;

/**
 * A tree that stores BoardStates along with their heuristic score.
 */
public class Tree<T> {
	private Node<T> root;

    public Tree(T rootData) {
        root = new Node<T>();
        root.setData(rootData);
        root.children = new ArrayList<Node<T>>();
    }

    public static class Node<T> {
        private T data;
        private Node<T> parent;
        private List<Node<T>> children;
        
        
		public T getData() {
			return data;
		}
		public void setData(T data) {
			this.data = data;
		}
    }
}

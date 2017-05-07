package SudokuSolver;

import java.util.*;
import java.io.*;


class Sudoku
{
    /* SIZE is the size parameter of the Sudoku puzzle, and N is the square of the size.  For 
     * a standard Sudoku puzzle, SIZE is 3 and N is 9. */
    int SIZE, N;

    /* The grid contains all the numbers in the Sudoku puzzle.  Numbers which have
     * not yet been revealed are stored as 0. */
    int Grid[][];


    /* The solve() method should remove all the unknown characters ('x') in the Grid
     * and replace them with the numbers from 1-9 that satisfy the Sudoku puzzle. */

    /*TO SEE BACKTRACKING PROCCESS, UNCOMMENT PRINT STATEMENTS*/
    public void solve()
    {
    	Stack<Integer> st = new Stack<Integer>();
    	System.out.println("  Solved Sudoku:");
    	int x=0, y=0, k=1;
    	solve:
    	while (x < N){
	    	if (Grid[x][y]==0){
	    		while (k<=N){
	    			//System.out.printf("Checking if Grid[%d][%d]=%d works\n",x,y,k);
	    			if (cellCheck(x, y, k)) {
	    				st.push(k);			//remember these values
						  st.push(y);			//stack has all the x,y,k that were changed
	    				st.push(x);
						  Grid[x][y] = k;		//when cellCheck returns true, set Grid[x][y] to k
						  //System.out.printf("Value works. Setting Grid[%d][%d]= %d\n",x,y,k);
						  k=1;
						  break;
	    			} else if (k==N && !cellCheck(x, y, k)) { //if k= last value & doesnt work
	    				Grid[x][y] = 0;
  						//System.out.printf("Grid[%d][%d] failed.\n",x,y);
  						if (st.empty()) {
  							//System.out.printf("Stack Empty. Bactracking...\n");
  							//System.out.printf("Cell [%d][%d]\n", x,y);
  							x++;
  							if (x == N){ //reached cell [9][y] which doesn't exist so reset x
  	    						x = 0;
  	    						y++;
  	    					}
  							k = 1;
  							continue;
  						}
  						x = st.pop();
  						y = st.pop();
  						k = st.pop() + 1;
  						//System.out.printf("Backracking to Cell [%d][%d], %d\n", x,y,k);
  						while (k==(N+1)) { //If last cell had value 9, backtrack again
  							Grid[x][y] = 0;
  							if (st.empty()) {
  								//System.out.printf("Stack Empty. Bactracking...\n");
  								//System.out.printf("Cell [%d][%d]\n", x,y);
  								x++;
  								if (x == N){ //reached cell [9][y] which doesn't exist so rest x
  		    						x = 0;
  		    						y++;
  		    					}
  								k = 1;
  								continue;
  							}
  							x = st.pop();
  							y = st.pop();
  							k = st.pop() + 1;
  							//System.out.printf("Backracking to Cell [%d][%d], %d\n", x,y,k);
						  }
						  continue;
	    			} else {
	    				k++;
					}
				}
	    	} else {
		    	//System.out.printf("/!\\ ");
	    		x++;
		    	if (x == N){ //reached cell [9][y] which doesn't exist so reset x
		    		x = 0;
		    		y++;
		    		if (y == N){ //reached cell [8][9] which doesn't exist
		    			//check to see if the sudoku is complete
				        for (int row = 0; row<N; row++) {
				        	for (int col = 0; col<N; col++) {
				        		if (Grid[row][col] == 0) {
				        			x = row;
				        			y = col;
				        			continue solve;
				        		}
				        	}
				        }
		    			break;
		    		}
		    	}
	    	}
    	}
    }

    //returns True if the value k doesn't exist in the same row or column as Grid[row][col]
    public boolean cellCheck(int row, int col, int k)
    {
    	//check if that value already exists in this row
    	for (int i=0; i<N; i++)
    		if (Grid[row][i]==k) return false;
    	//check if that value already exists in this column
        for (int j=0; j<N; j++)
       		if (Grid[j][col]==k) return false;

       	//check if that value already exist in this square
       	int rstart = row - (row % SIZE);
       	int cstart = col - (col % SIZE);
       	for (int i=rstart; i<rstart+SIZE; i++) {
    		for (int j=cstart; j<cstart+SIZE; j++){
    			if (Grid[i][j]==k) {
    				return false;
    			}
    		}
    	}
       	
        return true;
    }


    /*****************************************************************************/
    /* NOTE: YOU SHOULD NOT HAVE TO MODIFY ANY OF THE FUNCTIONS BELOW THIS LINE. */
    /*****************************************************************************/
 
    /* Default constructor.  This will initialize all positions to the default 0
     * value.  Use the read() function to load the Sudoku puzzle from a file or
     * the standard input. */
    public Sudoku( int size )
    {
        SIZE = size;
        N = size*size;

        Grid = new int[N][N];
        for( int i = 0; i < N; i++ ) 
            for( int j = 0; j < N; j++ ) 
                Grid[i][j] = 0;
    }


    /* readInteger is a helper function for the reading of the input file.  It reads
     * words until it finds one that represents an integer. For convenience, it will also
     * recognize the string "x" as equivalent to "0". */
    static int readInteger( InputStream in ) throws Exception
    {
        int result = 0;
        boolean success = false;

        while( !success ) {
            String word = readWord( in );

            try {
                result = Integer.parseInt( word );
                success = true;
            } catch( Exception e ) {
                // Convert 'x' words into 0's
                if( word.compareTo("x") == 0 ) {
                    result = 0;
                    success = true;
                }
                // Ignore all other words that are not integers
            }
        }

        return result;
    }


    /* readWord is a helper function that reads a word separated by white space. */
    static String readWord( InputStream in ) throws Exception
    {
        StringBuffer result = new StringBuffer();
        int currentChar = in.read();
        String whiteSpace = " \t\r\n";
        // Ignore any leading white space
        while( whiteSpace.indexOf(currentChar) > -1 ) {
            currentChar = in.read();
        }

        // Read all characters until you reach white space
        while( whiteSpace.indexOf(currentChar) == -1 ) {
            result.append( (char) currentChar );
            currentChar = in.read();
        }
        return result.toString();
    }


    /* This function reads a Sudoku puzzle from the input stream in.  The Sudoku
     * grid is filled in one row at at time, from left to right.  All non-valid
     * characters are ignored by this function and may be used in the Sudoku file
     * to increase its legibility. */
    public void read( InputStream in ) throws Exception
    {
        for( int i = 0; i < N; i++ ) {
            for( int j = 0; j < N; j++ ) {
                Grid[i][j] = readInteger( in );
            }
        }
    }


    /* Helper function for the printing of Sudoku puzzle.  This function will print
     * out text, preceded by enough ' ' characters to make sure that the printint out
     * takes at least width characters.  */
    void printFixedWidth( String text, int width )
    {
        for( int i = 0; i < width - text.length(); i++ )
            System.out.print( " " );
        System.out.print( text );
    }


    /* The print() function outputs the Sudoku grid to the standard output, using
     * a bit of extra formatting to make the result clearly readable. */
    public void print()
    {
        // Compute the number of digits necessary to print out each number in the Sudoku puzzle
        int digits = (int) Math.floor(Math.log(N) / Math.log(10)) + 1;

        // Create a dashed line to separate the boxes 
        int lineLength = (digits + 1) * N + 2 * SIZE - 3;
        StringBuffer line = new StringBuffer();
        for( int lineInit = 0; lineInit < lineLength; lineInit++ )
            line.append('-');

        // Go through the Grid, printing out its values separated by spaces
        for( int i = 0; i < N; i++ ) {
            for( int j = 0; j < N; j++ ) {
                printFixedWidth( String.valueOf( Grid[i][j] ), digits );
                // Print the vertical lines between boxes 
                if( (j < N-1) && ((j+1) % SIZE == 0) )
                    System.out.print( " |" );
                System.out.print( " " );
            }
            System.out.println();

            // Print the horizontal line between boxes
            if( (i < N-1) && ((i+1) % SIZE == 0) )
                System.out.println( line.toString() );
        }
    }


    /* The main function reads in a Sudoku puzzle from the standard input, 
     * unless a file name is provided as a run-time argument, in which case the
     * Sudoku puzzle is loaded from that file.  It then solves the puzzle, and
     * outputs the completed puzzle to the standard output. */
    public static void main( String args[] ) throws Exception
    {
        InputStream in;
        if( args.length > 0 ) 
            in = new FileInputStream( args[0] );
        else
            in = System.in;

        // The first number in all Sudoku files must represent the size of the puzzle.  See
        // the example files for the file format.
        int puzzleSize = readInteger( in );
        if( puzzleSize > 100 || puzzleSize < 1 ) {
            System.out.println("Error: The Sudoku puzzle size must be between 1 and 100.");
            System.exit(-1);
        }

        Sudoku s = new Sudoku( puzzleSize );

        // read the rest of the Sudoku puzzle
        s.read( in );

        // Solve the puzzle.  We don't currently check to verify that the puzzle can be
        // successfully completed.  You may add that check if you want to, but it is not
        // necessary.
        long startTime = System.nanoTime();
        s.solve();
        long endTime = System.nanoTime();
        long duration = (endTime - startTime)/1000000;

        // Print out the (hopefully completed!) puzzle
        s.print();

        System.out.println("Time taken in milliseconds :" + duration);
    }
}


/* @pjs preload="processing/pieces/wQ.png,processing/pieces/wK.png,processing/pieces/wR.png,processing/pieces/wB.png, processing/pieces/wN.png, processing/pieces/wP.png"; crisp="true"; */ 
/* @pjs preload="processing/pieces/bQ.png,processing/pieces/bK.png,processing/pieces/bR.png,processing/pieces/bB.png, processing/pieces/bN.png, processing/pieces/bP.png"; crisp="true"; */ 

String[] FILES = {"a", "b", "c", "d", "e", "f", "g", "h"};
String[] RANKS = {"1", "2", "3", "4", "5", "6", "7", "8"};
ChessBoard chessBoard = null;
final int SQUARE_WIDTH = 100;
final int SQUARE_HEIGHT = 100;
final int BOARD_WIDTH = SQUARE_WIDTH * 8;
final int BOARD_HEIGHT = SQUARE_HEIGHT * 8;
final String IMG_PATH = "processing/pieces/";
String g_currentFile = null;
String g_currentRank = null;
Square g_currentSquare = null;
Square g_selectedSquare = null;
ChessPiece g_currentPiece = null;
//Pfont font;
boolean bCanCastleShort = true, bCanCastleLong = true;
boolean wCanCastleShort = true, wCanCastleLong = true;
/* #################### NATIVE PROCESSING START #################### */

void setup() {
  size(BOARD_WIDTH, BOARD_HEIGHT);
  rectMode(CORNER);
  imageMode(CORNER);
  //font = loadFont("OpenSans-Regular.ttf");
  //textFont(font, 32);
  chessBoard = new ChessBoard();
}

void draw(){
  chessBoard.draw();
  if (g_currentPiece != null){
    g_currentPiece.draw();
  }
}

/*void mouseClicked(){
  if (g_selectedSquare != null && !g_selectedSquare.empty()){
    g_currentSquare.placePiece(g_selectedSquare.piece);
  }
}*/

void mousePressed(){
  if (!g_currentSquare.empty()){
    g_currentPiece = g_currentSquare.piece;
    g_currentPiece.followMouse = true;
  }
  g_selectedSquare = g_currentSquare;
}

void mouseReleased(){
  if (g_currentPiece != null){
    g_currentSquare.placePiece(g_currentPiece);
    g_currentPiece.followMouse = false;
    g_currentPiece = null;
  }
}

void mouseDragged(){
  squareHover();
}

void mouseMoved() {
  squareHover();
}

void squareHover(){
  if (mouseX > BOARD_WIDTH - SQUARE_WIDTH){
    g_currentFile = "h";
  } else if (mouseX > BOARD_WIDTH - 2 * SQUARE_WIDTH){
    g_currentFile = "g";
  } else if (mouseX > BOARD_WIDTH - 3 * SQUARE_WIDTH){
    g_currentFile = "f";
  } else if (mouseX > BOARD_WIDTH - 4 * SQUARE_WIDTH){
    g_currentFile = "e";
  } else if (mouseX > BOARD_WIDTH - 5 * SQUARE_WIDTH){
    g_currentFile = "d";
  } else if (mouseX > BOARD_WIDTH - 6 * SQUARE_WIDTH){
    g_currentFile = "c";
  } else if (mouseX > BOARD_WIDTH - 7 * SQUARE_WIDTH){
    g_currentFile = "b";
  }  else if (mouseX > BOARD_WIDTH - 8 * SQUARE_WIDTH){
    g_currentFile = "a";
  }

  if (mouseY > BOARD_HEIGHT - SQUARE_HEIGHT){
    g_currentRank = "1";
  } else if (mouseY > BOARD_HEIGHT - 2 * SQUARE_HEIGHT){
    g_currentRank = "2";
  } else if (mouseY > BOARD_HEIGHT - 3 * SQUARE_HEIGHT){
    g_currentRank = "3";
  } else if (mouseY > BOARD_HEIGHT - 4 * SQUARE_HEIGHT){
    g_currentRank = "4";
  } else if (mouseY > BOARD_HEIGHT - 5 * SQUARE_HEIGHT){
    g_currentRank = "5";
  } else if (mouseY > BOARD_HEIGHT - 6 * SQUARE_HEIGHT){
    g_currentRank = "6";
  } else if (mouseY > BOARD_HEIGHT - 7 * SQUARE_HEIGHT){
    g_currentRank = "7";
  }  else if (mouseY > BOARD_HEIGHT - 8 * SQUARE_HEIGHT){
    g_currentRank = "8";
  }

  if (g_currentSquare != null){
    g_currentSquare.highlight = false;
  }
  g_currentSquare = chessBoard.getSquare(g_currentFile, g_currentRank);
  g_currentSquare.highlight = true;
}

void mouseOut(){
  chessBoard.getSquare(g_currentFile, g_currentRank).highlight = false;
  g_currentFile = null;
  g_currentRank = null;
  g_currentSquare = null;
  if (g_currentPiece != null){
    g_currentPiece.followMouse = false;
    g_currentPiece = null;
  }
}

/* #################### NATIVE PROCESSING END #################### */


/* #################### CHESSBOARD START #################### */
class ChessBoard {
  ArrayList<Square> squares;
  ArrayList<ChessPiece> whitePieces;
  ArrayList<ChessPiece> blackPieces;

  HashMap<ArrayList<Square>> files;


  ChessBoard() {
    this.files = new HashMap<ArrayList<Square>>();
    this.squares = new ArrayList<Square>();
    this.whitePieces = new ArrayList<ChessPiece>();
    this.blackPieces = new ArrayList<ChessPiece>();

    String color = "b";
    int x = 0, y;
    for (int i = 0; i < FILES.length; i++){
      HashMap<Square> ranks = new HashMap<Square>();
      String file = FILES[i];
      y = (int)height - SQUARE_HEIGHT;

      for (int j = 0; j < RANKS.length; j++){
        String rank  = RANKS[j];
        Square square = new Square((float)x, (float)y, file, rank, color);

        /* Add Piece To Square */
        if (square.rank.equals("1")){
          if (square.file.equals("a") || square.file.equals("h")){
            ChessPiece rook = new Rook("w");
            square.placePiece(rook);
            whitePieces.add(rook);
          } else if (square.file.equals("b") || square.file.equals("g")){
            ChessPiece knight = new Knight("w");
            square.placePiece(knight);
            whitePieces.add(knight);
          } else if (square.file.equals("c") || square.file.equals("f")){
            ChessPiece bishop = new Bishop("w");
            square.placePiece(bishop);
            whitePieces.add(bishop);
          } else if (square.file.equals("d")){
            ChessPiece queen = new Queen("w");
            square.placePiece(queen);
            whitePieces.add(queen);
          } else if (square.file.equals("e")){
            ChessPiece king = new King("w");
            square.placePiece(king);
            whitePieces.add(king);
          }
        } else if (square.rank.equals("2")){
          ChessPiece pawn = new Pawn("w");
          square.placePiece(pawn);
          whitePieces.add(pawn);
        }
        else if (square.rank.equals("7")){
          ChessPiece pawn = new Pawn("b");
          square.placePiece(pawn);
          blackPieces.add(pawn);
        }
        else if (square.rank.equals("8")){
          if (square.file.equals("a") || square.file.equals("h")){
            ChessPiece rook = new Rook("b");
            square.placePiece(rook);
            blackPieces.add(rook);
          } else if (square.file.equals("b") || square.file.equals("g")){
            ChessPiece knight = new Knight("b");
            square.placePiece(knight);
            blackPieces.add(knight);
          } else if (square.file.equals("c") || square.file.equals("f")){
            ChessPiece bishop = new Bishop("b");
            square.placePiece(bishop);
            blackPieces.add(bishop);
          } else if (square.file.equals("d")){
            ChessPiece queen = new Queen("b");
            square.placePiece(queen);
            blackPieces.add(queen);
          } else if (square.file.equals("e")){
            ChessPiece king = new King("b");
            square.placePiece(king);
            blackPieces.add(king);
          }
        }
        /* End Add Piece */

        y -= SQUARE_HEIGHT;
        this.squares.add(square);
        ranks.put(rank, square);
        if (color.equals("b") && j != RANKS.length - 1){
          color = "w";
        }
        else if (color.equals("w") && j != RANKS.length - 1){
          color = "b";
        }
      }
      this.files.put(file, ranks);
      x += SQUARE_WIDTH;
    }
  }

  Square getSquare(String file, String rank){
    return this.files.get(file).get(rank);
  }

  void draw(){
    for (int i = 0; i < FILES.length; i++){
      String file = FILES[i];

      for (int j = 0; j < RANKS.length; j++){
        String rank = RANKS[j];
        Square square = this.getSquare(file, rank);
        square.draw();
      }
    }
  }
}

/* #################### CHESSBOARD END #################### */

/* #################### SQUARE START #################### */

class Square {
  String file, rank, color;
  float x, y;
  float width, height;
  ChessPiece piece;
  boolean highlight;

  Square(float x, float y, String file, String rank, String color){
    this.x = x;
    this.y = y;

    this.width = (float)SQUARE_WIDTH;
    this.height = (float)SQUARE_HEIGHT;

    this.file = file;
    this.rank = rank;
    this.color = color;

    this.piece = null;

    this.highlight = false;
  }

  boolean empty(){
    return this.piece == null;
  }

  boolean placePiece(ChessPiece piece){
    
    if (piece.placeOn(this)){
      if (!this.empty()){
        this.piece.square = null;
      }
      this.piece = piece;
      return true;
    }
    return false;
  }

  void draw(){
    if (this.color.equals("w")){
      fill(255, 204, 153);
    }
    else{
      fill(128, 64, 0);
    }

    rect(this.x, this.y, this.width, this.height);

    if (this.highlight || this.equals(g_selectedSquare)){
      fill(255, 255, 102, 50);
      rect(this.x, this.y, this.width, this.height);
    }

    if (!this.empty() && this.piece != g_currentPiece){
      this.piece.draw();
    }
  }
}

/* #################### SQUARE END #################### */

/* #################### CHESSPIECE START #################### */

interface ChessPiece {
  PImage icon;
  String name;
  String currentFile, currentRank;
  String color;
  Square currentSquare;
  boolean followMouse;
  HashMap<Square> attackingSquares;

  void draw();
  boolean placeOn(Square square);
  void calcSquares();
}

class Piece implements ChessPiece {
  PImage icon;
  String name;
  String currentFile, currentRank;
  String color;
  Square currentSquare;
  Boolean followMouse;
  HashMap<Square> attackingSquares;

  Piece(String name, String img_path, String color){
    this.name = name;
    this.icon = loadImage(img_path);
    this.color = color;

    this.currentSquare = null;
    this.currentFile = null;
    this.currentRank = null;

    this.followMouse = false;
    attackingSquares = new HashMap<Square>();
  }

  void draw(){
    if (this.followMouse){
      image(this.icon, mouseX - SQUARE_WIDTH / 2, mouseY - SQUARE_HEIGHT / 2, SQUARE_WIDTH, SQUARE_HEIGHT);
    } else {
      image(this.icon, this.currentSquare.x, this.currentSquare.y, SQUARE_WIDTH, SQUARE_HEIGHT);
    }
  }

  boolean placeOn(Square square){
    if (this.currentSquare != null){
      this.currentSquare.piece = null;
    }

    this.currentSquare = square;
    this.currentFile = square.file;
    this.currentRank = square.rank;
    return true;
  }

  void calcSquares(){
  }
}

class King extends Piece {

  King(String color){
    super("king", IMG_PATH + color + "K.png", color);
  }

  boolean placeOn(Square square){
    if (this.currentSquare != null){
        this.calcSquares();
        if (this.attackingSquares.get(square) == null){
         return false;
        }
      this.currentSquare.piece = null;
    }
    this.currentSquare = square;
    this.currentFile = square.file;
    this.currentRank = square.rank;
    return true;
  }

  void calcSquares(){
    this.attackingSquares.clear();
    this.attackingSquares.put(this.currentSquare, true);
    if (this.color == "w"){
      if (wCanCastleShort){
        // Add two right square
      }
      if (wCanCastleLong){
        // Add two left square
      }
    } else {
      if (bCanCastleShort){
        // Add two left square
      }
      if (bCanCastleLong){
        // Add two right square
      }
    }

    // Calculate all adjacent squares
    int fileIndex = FILES.indexOf(this.currentFile);
    int rankIndex = RANKS.indexOf(this.currentRank);
    boolean onTopEdge = false, onBottomEdge = false, onLeftEdge = false, onRightEdge = false;

    if (fileIndex == 0){
      onLeftEdge = true;
    } else if (fileIndex == 7){
      onRightEdge = true;
    }
    if (rankIndex == 0){
      onBottomEdge = true;
    } else if (rankIndex == 7){
      onTopEdge = true;
    }

    // Not on left edge
    if (!onLeftEdge){
      // Get direct left square from king
      String file = FILES[fileIndex - 1];
      String rank = this.currentRank;
      Square left = chessBoard.getSquare(file, rank);
      if (left.empty() || left.piece.color != this.color){
        this.attackingSquares.put(left, true);
      }
      
      // Not on bottom edge
      if (!onBottomEdge){
        // Get bottom left square from king
        rank = RANKS[rankIndex - 1];
        Square leftBottom = chessBoard.getSquare(file, rank);
        if (leftBottom.empty() || leftBottom.piece.color != this.color){
          this.attackingSquares.put(leftBottom, true);
        }
      }
      // Not on top edge
      if (!onTopEdge){
        // Get top left square from king
        rank = RANKS[rankIndex + 1];
        Square leftTop = chessBoard.getSquare(file, rank);
        if (leftTop.empty() || leftTop.piece.color != this.color){
          this.attackingSquares.put(leftTop, true);
        }
      }
    }

    // Get direct bottom square from king
    if (!onBottomEdge){
      String file = this.currentFile;
      String rank = RANKS[rankIndex - 1];
      Square bottom = chessBoard.getSquare(file, rank);
      if (bottom.empty() || bottom.piece.color != this.color){
        this.attackingSquares.put(bottom, true);
      }
    }
    // Get direct top square from king
    if (!onTopEdge){
      String file = this.currentFile;
      String rank = RANKS[rankIndex + 1];
      Square top = chessBoard.getSquare(file, rank);
      if (top.empty() || top.piece.color != this.color){
        this.attackingSquares.put(top, true);
      }
    }

    // Not on right edge
    if (!onRightEdge){
      // Get direct right square from king
      String file = FILES[fileIndex + 1];
      String rank = this.currentRank;
      Square right = chessBoard.getSquare(file, rank);
      if (right.empty() || right.piece.color != this.color){
        this.attackingSquares.put(right, true);
      }
      
      // Not on bottom edge
      if (!onBottomEdge){
        // Get bottom right square from king
        rank = RANKS[rankIndex - 1];
        Square rightBottom = chessBoard.getSquare(file, rank);
        if (rightBottom.empty() || rightBottom.piece.color != this.color){
          this.attackingSquares.put(rightBottom, true);
        }
      }
      // Not on top edge
      if (!onTopEdge){
        // Get top right square from king
        rank = RANKS[rankIndex + 1];
        Square rightTop = chessBoard.getSquare(file, rank);
        if (rightTop.empty() || rightTop.piece.color != this.color){
          this.attackingSquares.put(rightTop, true);
        }
      }
    }
  }
}

class Queen extends Piece {

  Queen(String color){
    super("queen", IMG_PATH + color + "Q.png", color);
  }

  void calcSquares(){

  }
}

class Rook extends Piece {

  Rook(String color){
    super("rook", IMG_PATH + color + "R.png", color);
  }

  boolean placeOn(Square square){
    if (this.currentSquare != null){
        this.calcSquares();
        if (this.attackingSquares.get(square) == null){
         return false;
        }
      this.currentSquare.piece = null;
    }
    this.currentSquare = square;
    this.currentFile = square.file;
    this.currentRank = square.rank;
    return true;
  }

  void calcSquares(){
    this.attackingSquares.clear();
    this.attackingSquares.put(this.currentSquare, true);

    int fileIndex = FILES.indexOf(this.currentFile);
    int rankIndex = RANKS.indexOf(this.currentRank);
    int tempFile = fileIndex;
    int tempRank = rankIndex;
    boolean onTopEdge = false, onBottomEdge = false, onLeftEdge = false, onRightEdge = false;

    if (fileIndex == 0){
      onLeftEdge = true;
    } else if (fileIndex == 7){
      onRightEdge = true;
    }
    if (rankIndex == 0){
      onBottomEdge = true;
    } else if (rankIndex == 7){
      onTopEdge = true;
    }

    while (!onTopEdge){
      String file = this.currentFile;
      String rank = RANKS[++tempRank];
      if (tempRank == 7){
        onTopEdge = true;
      }
      Square above = chessBoard.getSquare(file, rank);
      if (above.empty() || above.piece.color != this.color){
        this.attackingSquares.put(above, true);
      }
      if (!above.empty()){
        break;
      }
    }

    tempFile = fileIndex;
    tempRank = rankIndex;

    while (!onBottomEdge){
      String file = this.currentFile;
      String rank = RANKS[--tempRank];
      if (tempRank == 0){
        onBottomEdge = true;
      }
      Square below = chessBoard.getSquare(file, rank);
      if (below.empty() || below.piece.color != this.color){
        this.attackingSquares.put(below, true);
      }
      if (!below.empty()){
        break;
      }
    }

    tempFile = fileIndex;
    tempRank = rankIndex;

    while (!onRightEdge){
      String file = FILES[++tempFile];
      if (tempFile == 7){
        onRightEdge = true;
      } else {
        onRightEdge = false;
      }
      String rank = this.currentRank;
      Square right = chessBoard.getSquare(file, rank);
      if (right.empty() || right.piece.color != this.color){
        this.attackingSquares.put(right, true);
      }
      if (!right.empty()){
        break;
      }
    }

    tempFile = fileIndex;
    tempRank = rankIndex;

    while (!onLeftEdge){
      String file = FILES[--tempFile];
      if (tempFile == 0){
        onLeftEdge = true;
      } else {
        onLeftEdge = false;
      }
      String rank = this.currentRank;
      Square left = chessBoard.getSquare(file, rank);
      if (left.empty() || left.piece.color != this.color){
        this.attackingSquares.put(left, true);
      }
      if (!left.empty()){
        break;
      }
    }

  }
}

class Bishop extends Piece {

  Bishop(String color){
    super("bishop", IMG_PATH + color + "B.png", color);
  }

  boolean placeOn(Square square){
    if (this.currentSquare != null){
        this.calcSquares();
        if (this.attackingSquares.get(square) == null){
         return false;
        }
      this.currentSquare.piece = null;
    }
    this.currentSquare = square;
    this.currentFile = square.file;
    this.currentRank = square.rank;
    return true;
  }

  void calcSquares(){
    this.attackingSquares.clear();
    this.attackingSquares.put(this.currentSquare, true);

    int fileIndex = FILES.indexOf(this.currentFile);
    int rankIndex = RANKS.indexOf(this.currentRank);
    int tempFile = fileIndex;
    int tempRank = rankIndex;
    boolean onTopEdge = false, onBottomEdge = false, onLeftEdge = false, onRightEdge = false;

    if (fileIndex == 0){
      onLeftEdge = true;
    } else if (fileIndex == 7){
      onRightEdge = true;
    }
    if (rankIndex == 0){
      onBottomEdge = true;
    } else if (rankIndex == 7){
      onTopEdge = true;
    }

    while (!onTopEdge && !onRightEdge){
      String file = FILES[++tempFile];
      String rank = RANKS[++tempRank];
      if (tempRank == 7){
        onTopEdge = true;
      }

      if (tempFile == 7){
        onRightEdge = true;
      }
      Square topRight = chessBoard.getSquare(file, rank);
      if (topRight.empty() || topRight.piece.color != this.color){
        this.attackingSquares.put(topRight, true);
      }
      if (!topRight.empty()){
        break;
      }
    }

    tempFile = fileIndex;
    tempRank = rankIndex;

    onTopEdge = onBottomEdge = onLeftEdge = onRightEdge = false;

    if (fileIndex == 0){
      onLeftEdge = true;
    } else if (fileIndex == 7){
      onRightEdge = true;
    }
    if (rankIndex == 0){
      onBottomEdge = true;
    } else if (rankIndex == 7){
      onTopEdge = true;
    }

    while (!onTopEdge && !onLeftEdge){
      String file = FILES[--tempFile];
      String rank = RANKS[++tempRank];

      if (tempRank == 7){
        onTopEdge = true;
      }

      if (tempFile == 0){
        onLeftEdge = true;
      }
      
      Square topLeft = chessBoard.getSquare(file, rank);
      if (topLeft.empty() || topLeft.piece.color != this.color){
        this.attackingSquares.put(topLeft, true);
      }
      if (!topLeft.empty()){
        break;
      }
    }

    tempFile = fileIndex;
    tempRank = rankIndex;

    onTopEdge = onBottomEdge = onLeftEdge = onRightEdge = false;

    if (fileIndex == 0){
      onLeftEdge = true;
    } else if (fileIndex == 7){
      onRightEdge = true;
    }
    if (rankIndex == 0){
      onBottomEdge = true;
    } else if (rankIndex == 7){
      onTopEdge = true;
    }

    while (!onBottomEdge && !onRightEdge){
      String file = FILES[++tempFile];
      String rank = RANKS[--tempRank];

      if (tempRank == 0){
        onBottomEdge = true;
      }

      if (tempFile == 7){
        onRightEdge = true;
      }
      
      Square bottomRight = chessBoard.getSquare(file, rank);
      if (bottomRight.empty() || bottomRight.piece.color != this.color){
        this.attackingSquares.put(bottomRight, true);
      }
      if (!bottomRight.empty()){
        break;
      }
    }

    tempFile = fileIndex;
    tempRank = rankIndex;

    onTopEdge = onBottomEdge = onLeftEdge = onRightEdge = false;

    if (fileIndex == 0){
      onLeftEdge = true;
    } else if (fileIndex == 7){
      onRightEdge = true;
    }
    if (rankIndex == 0){
      onBottomEdge = true;
    } else if (rankIndex == 7){
      onTopEdge = true;
    }

    while (!onBottomEdge && !onLeftEdge){
      String file = FILES[--tempFile];
      String rank = RANKS[--tempRank];

      if (tempRank == 0){
        onBottomEdge = true;
      }

      if (tempFile == 0){
        onLeftEdge = true;
      }
      
      Square bottomLeft = chessBoard.getSquare(file, rank);
      if (bottomLeft.empty() || bottomLeft.piece.color != this.color){
        this.attackingSquares.put(bottomLeft, true);
      }
      if (!bottomLeft.empty()){
        break;
      }
    }
  }
}

class Knight extends Piece {

  Knight(String color){
    super("knight", IMG_PATH + color + "N.png", color);
  }

  boolean placeOn(Square square){
    if (this.currentSquare != null){
        this.calcSquares();
        if (this.attackingSquares.get(square) == null){
         return false;
        }
      this.currentSquare.piece = null;
    }
    this.currentSquare = square;
    this.currentFile = square.file;
    this.currentRank = square.rank;
    return true;
  }

  void calcSquares(){
    this.attackingSquares.clear();
    this.attackingSquares.put(this.currentSquare, true);

    // Calculate all adjacent squares
    int fileIndex = FILES.indexOf(this.currentFile);
    int rankIndex = RANKS.indexOf(this.currentRank);

    // Not on right edge
    if (rankIndex + 2 < 8){
      // Get right square from knight
      String rank = RANKS[rankIndex + 2];

      if (fileIndex + 1 < 8){
        String file = FILES[fileIndex + 1];
        Square right = chessBoard.getSquare(file, rank);
        if (right.empty() || right.piece.color != this.color){
          this.attackingSquares.put(right, true);
        }
      }

      if (fileIndex - 1 >= 0){
        String file = FILES[fileIndex - 1];
        Square left = chessBoard.getSquare(file, rank);
        if (left.empty() || left.piece.color != this.color){
          this.attackingSquares.put(left, true);
        }
      }
    }

    if (rankIndex + 1 < 8){
      // Get right square from knight
      String rank = RANKS[rankIndex + 1];

      if (fileIndex + 2 < 8){
        String file = FILES[fileIndex + 2];
        Square right = chessBoard.getSquare(file, rank);
        if (right.empty() || right.piece.color != this.color){
          this.attackingSquares.put(right, true);
        }
      }

      if (fileIndex - 2 >= 0){
        String file = FILES[fileIndex - 2];
        Square left = chessBoard.getSquare(file, rank);
        if (left.empty() || left.piece.color != this.color){
          this.attackingSquares.put(left, true);
        }
      }
    }

    if (rankIndex - 2 >= 0){
      // Get right square from knight
      String rank = RANKS[rankIndex - 2];

      if (fileIndex + 1 < 8){
        String file = FILES[fileIndex + 1];
        Square right = chessBoard.getSquare(file, rank);
        if (right.empty() || right.piece.color != this.color){
          this.attackingSquares.put(right, true);
        }
      }

      if (fileIndex - 1 >= 0){
        String file = FILES[fileIndex - 1];
        Square left = chessBoard.getSquare(file, rank);
        if (left.empty() || left.piece.color != this.color){
          this.attackingSquares.put(left, true);
        }
      }
    }

    if (rankIndex - 1 >= 0){
      // Get right square from knight
      String rank = RANKS[rankIndex - 1];

      if (fileIndex + 2 < 8){
        String file = FILES[fileIndex + 2];
        Square right = chessBoard.getSquare(file, rank);
        if (right.empty() || right.piece.color != this.color){
          this.attackingSquares.put(right, true);
        }
      }

      if (fileIndex - 2 >= 0){
        String file = FILES[fileIndex - 2];
        Square left = chessBoard.getSquare(file, rank);
        if (left.empty() || left.piece.color != this.color){
          this.attackingSquares.put(left, true);
        }
      }
    }
  }
}

class Pawn extends Piece {

  boolean firstMove = true;

  Pawn(String color){
    super("pawn", IMG_PATH + color + "P.png", color);
  }

  boolean placeOn(Square square){
    if (this.currentSquare != null){
      this.calcSquares();
      if (this.attackingSquares.get(square) == null){
       return false;
      }
      if (this.currentSquare != square){
        this.firstMove = false;
        this.currentSquare.piece = null;
      }
    }
    this.currentSquare = square;
    this.currentFile = square.file;
    this.currentRank = square.rank;
    return true;
  }

  void calcSquares(){
    this.attackingSquares.clear();
    this.attackingSquares.put(this.currentSquare, true);

    // Calculate all adjacent squares
    int fileIndex = FILES.indexOf(this.currentFile);
    int rankIndex = RANKS.indexOf(this.currentRank);

    if (this.color.equals("w")){
      String file = this.currentFile;
      String rank = RANKS[rankIndex + 1];
      Square above = chessBoard.getSquare(file, rank);
      if (above.empty()){
        this.attackingSquares.put(above, true);
      }

      if (firstMove){
        rank = RANKS[rankIndex + 2];
        Square twoAbove = chessBoard.getSquare(file, rank);
        if (twoAbove.empty()){
          this.attackingSquares.put(twoAbove, true);
        }
      }

      if (fileIndex + 1 < 8){
        file = FILES[fileIndex + 1];
        rank = RANKS[rankIndex + 1];
        Square right = chessBoard.getSquare(file, rank);
        if (!right.empty() && right.piece.color != this.color){
          this.attackingSquares.put(right, true);
        }
      }

      if (fileIndex - 1 >= 0){
        file = FILES[fileIndex - 1];
        rank = RANKS[rankIndex + 1];
        Square left = chessBoard.getSquare(file, rank);
        if (!left.empty() && left.piece.color != this.color){
          this.attackingSquares.put(left, true);
        }
      }
    } else {
      String file = this.currentFile;
      String rank = RANKS[rankIndex - 1];
      Square above = chessBoard.getSquare(file, rank);
      if (above.empty()){
        this.attackingSquares.put(above, true);
      }

      if (firstMove){
        rank = RANKS[rankIndex - 2];
        Square twoAbove = chessBoard.getSquare(file, rank);
        if (twoAbove.empty()){
          this.attackingSquares.put(twoAbove, true);
        }
      }

      if (fileIndex + 1 < 8){
        file = FILES[fileIndex + 1];
        rank = RANKS[rankIndex - 1];
        Square right = chessBoard.getSquare(file, rank);
        if (!right.empty() && right.piece.color != this.color){
          this.attackingSquares.put(right, true);
        }
      }

      if (fileIndex - 1 >= 0){
        file = FILES[fileIndex - 1];
        rank = RANKS[rankIndex - 1];
        Square left = chessBoard.getSquare(file, rank);
        if (!left.empty() && left.piece.color != this.color){
          this.attackingSquares.put(left, true);
        }
      }
    }

    
  }
}

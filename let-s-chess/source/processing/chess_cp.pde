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
String currentFile = null;
String currentRank = null;
Square currentSquare = null;
ChessPiece g_currentPiece = null;
Pfont font;

/* #################### NATIVE PROCESSING START #################### */

void setup() {
  size(BOARD_WIDTH, BOARD_HEIGHT);
  rectMode(CORNER);
  imageMode(CORNER);
  frameRate(40);
  chessBoard = new ChessBoard();

}

void draw(){
  chessBoard.draw();
  if (g_currentPiece != null){
    g_currentPiece.draw();
  }
}

void mouseDragged(){
  if (mouseX > BOARD_WIDTH - SQUARE_WIDTH){
    currentFile = "h";
  } else if (mouseX > BOARD_WIDTH - 2 * SQUARE_WIDTH){
    currentFile = "g";
  } else if (mouseX > BOARD_WIDTH - 3 * SQUARE_WIDTH){
    currentFile = "f";
  } else if (mouseX > BOARD_WIDTH - 4 * SQUARE_WIDTH){
    currentFile = "e";
  } else if (mouseX > BOARD_WIDTH - 5 * SQUARE_WIDTH){
    currentFile = "d";
  } else if (mouseX > BOARD_WIDTH - 6 * SQUARE_WIDTH){
    currentFile = "c";
  } else if (mouseX > BOARD_WIDTH - 7 * SQUARE_WIDTH){
    currentFile = "b";
  }  else if (mouseX > BOARD_WIDTH - 8 * SQUARE_WIDTH){
    currentFile = "a";
  }

  if (mouseY > BOARD_HEIGHT - SQUARE_HEIGHT){
    currentRank = "1";
  } else if (mouseY > BOARD_HEIGHT - 2 * SQUARE_HEIGHT){
    currentRank = "2";
  } else if (mouseY > BOARD_HEIGHT - 3 * SQUARE_HEIGHT){
    currentRank = "3";
  } else if (mouseY > BOARD_HEIGHT - 4 * SQUARE_HEIGHT){
    currentRank = "4";
  } else if (mouseY > BOARD_HEIGHT - 5 * SQUARE_HEIGHT){
    currentRank = "5";
  } else if (mouseY > BOARD_HEIGHT - 6 * SQUARE_HEIGHT){
    currentRank = "6";
  } else if (mouseY > BOARD_HEIGHT - 7 * SQUARE_HEIGHT){
    currentRank = "7";
  }  else if (mouseY > BOARD_HEIGHT - 8 * SQUARE_HEIGHT){
    currentRank = "8";
  }

  if (currentSquare != null){
    currentSquare.highlight = false;
  }
  currentSquare = chessBoard.files.get(currentFile).get(currentRank);
  currentSquare.highlight = true;
}

void mousePressed(){
  if (!currentSquare.empty()){
    g_currentPiece = currentSquare.piece;
    g_currentPiece.followMouse = true;
  }
}

void mouseReleased(){
  if (g_currentPiece != null){
    currentSquare.placePiece(g_currentPiece);
    g_currentPiece.followMouse = false;
    g_currentPiece = null;
  }
}

void mouseMoved() {
  if (mouseX > BOARD_WIDTH - SQUARE_WIDTH){
    currentFile = "h";
  } else if (mouseX > BOARD_WIDTH - 2 * SQUARE_WIDTH){
    currentFile = "g";
  } else if (mouseX > BOARD_WIDTH - 3 * SQUARE_WIDTH){
    currentFile = "f";
  } else if (mouseX > BOARD_WIDTH - 4 * SQUARE_WIDTH){
    currentFile = "e";
  } else if (mouseX > BOARD_WIDTH - 5 * SQUARE_WIDTH){
    currentFile = "d";
  } else if (mouseX > BOARD_WIDTH - 6 * SQUARE_WIDTH){
    currentFile = "c";
  } else if (mouseX > BOARD_WIDTH - 7 * SQUARE_WIDTH){
    currentFile = "b";
  }  else if (mouseX > BOARD_WIDTH - 8 * SQUARE_WIDTH){
    currentFile = "a";
  }

  if (mouseY > BOARD_HEIGHT - SQUARE_HEIGHT){
    currentRank = "1";
  } else if (mouseY > BOARD_HEIGHT - 2 * SQUARE_HEIGHT){
    currentRank = "2";
  } else if (mouseY > BOARD_HEIGHT - 3 * SQUARE_HEIGHT){
    currentRank = "3";
  } else if (mouseY > BOARD_HEIGHT - 4 * SQUARE_HEIGHT){
    currentRank = "4";
  } else if (mouseY > BOARD_HEIGHT - 5 * SQUARE_HEIGHT){
    currentRank = "5";
  } else if (mouseY > BOARD_HEIGHT - 6 * SQUARE_HEIGHT){
    currentRank = "6";
  } else if (mouseY > BOARD_HEIGHT - 7 * SQUARE_HEIGHT){
    currentRank = "7";
  }  else if (mouseY > BOARD_HEIGHT - 8 * SQUARE_HEIGHT){
    currentRank = "8";
  }

  if (currentSquare != null){
    currentSquare.highlight = false;
  }
  currentSquare = chessBoard.files.get(currentFile).get(currentRank);
  currentSquare.highlight = true;
}

void mouseOut(){
  chessBoard.files.get(currentFile).get(currentRank).highlight = false;
  currentFile = null;
  currentRank = null;
  currentSquare = null;
  g_currentPiece = null;
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

  void draw(){
    for (int i = 0; i < FILES.length; i++){
      HashMap<Square> rank = this.files.get(FILES[i]);

      for (int j = 0; j < RANKS.length; j++){
        Square square = rank.get(RANKS[j]);
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
    if (!this.empty()){
        this.piece.square = null;
    }
    if (piece.placeOn(this)){
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

    if (this.highlight){
      fill(255, 255, 102);
    }

    rect(this.x, this.y, this.width, this.height);

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

  void draw();
  boolean placeOn(Square square);
}

class Piece implements ChessPiece {
  PImage icon;
  String name;
  String currentFile, currentRank;
  String color;
  Square currentSquare;
  Boolean followMouse;

  Piece(String name, String img_path, String color){
    this.name = name;
    this.icon = loadImage(img_path);
    this.color = color;

    this.currentSquare = null;
    this.currentFile = null;
    this.currentRank = null;

    this.followMouse = false;
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
}

class King extends Piece {

  King(String color){
    super("king", IMG_PATH + color + "K.png", color);
  }
}

class Queen extends Piece {

  Queen(String color){
    super("queen", IMG_PATH + color + "Q.png", color);
  }
}

class Rook extends Piece {

  Rook(String color){
    super("rook", IMG_PATH + color + "R.png", color);
  }
}

class Bishop extends Piece {

  Bishop(String color){
    super("bishop", IMG_PATH + color + "B.png", color);
  }
}

class Knight extends Piece {

  Knight(String color){
    super("knight", IMG_PATH + color + "N.png", color);
  }
}

class Pawn extends Piece {

  Pawn(String color){
    super("pawn", IMG_PATH + color + "P.png", color);
  }
}

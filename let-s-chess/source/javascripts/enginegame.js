// Thank you nmrugg (check their work at github.com/nmrugg) for the awesome work and
// much of my inspiration for this project.

function engineGame(options) {
    options = options || {}
    var debugging = true;
    var game = new Chess();
    var board;
    var events = event_manager();
    var moves_manager = make_moves($('#chess-dash'), $('#chess-dash'));
    moves_manager.resize();
    var moves_history = [];
    // We can load Stockfish via Web Workers or via STOCKFISH() if loaded from a <script> tag.
    var engine = new Worker('javascripts/stockfish.js');
    var engine_other;
    var evaler = new Worker('javascripts/stockfish.js');

    var engineStatus = {};
    var displayScore = false;
    var time = { wtime: 300000, btime: 300000, winc: 2000, binc: 2000 };
    var playerColor = 'white';
    //var clockTimeoutID = null;
    var isEngineRunning = false;
    //var evaluation_el = document.getElementById("evaluation");
    var announced_game_over;
    var eval_w = 0.0, eval_b = 0.0;
    // do not pick up pieces if the game is over
    // only pick up pieces for White
    var onDragStart = function(source, piece, position, orientation) {
        var re = playerColor == 'white' ? /^b/ : /^w/
        if (game.game_over() ||
            piece.search(re) !== -1) {
            return false;
        }
    };

    function get_eval(score, turn, type){
      var display_score;
      if (type === "cp") {
          display_score = (score / 100).toFixed(2);
      } else if (score === 0) {
          if (turn === "w") {
              display_score = "0-1";
          } else {
              display_score = "1-0";
          }
      } else {
          display_score = "#" + score;
      }

      return display_score;
    }

    evaler.onmessage = function(event) {
        var line;

        if (event && typeof event === "object") {
            line = event.data;
        } else {
            line = event;
        }

        //console.log("evaler: " + line);

        /// Ignore some output.
        if (line === "uciok" || line === "readyok" || line.substr(0, 11) === "option name") {
            return;
        }

        // if (evaluation_el.textContent) {
        //     evaluation_el.textContent += "\n";
        // }
        //evaluation_el.textContent += line;
    };

    engine.onmessage = function(event) {
        var line,
            ply = moves_history.length;
        //console.log("black " + ply);

        if (event && typeof event === "object") {
            line = event.data;
        } else {
            line = event;
        }
        //console.log("Reply: " + line)
        if(line == 'uciok') {
            engineStatus.engineLoaded = true;
        } else if(line == 'readyok') {
            engineStatus.engineReady = true;
        } else {
            var match = line.match(/^bestmove ([a-h][1-8])([a-h][1-8])([qrbn])?/);
            /// Did the AI move?
            if(match) {
                isEngineRunning = false;
                var engine_move = game.move({from: match[1], to: match[2], promotion: match[3]});
                prepareMove(engine_move);
                //uciCmd("eval", evaler)
                //evaluation_el.textContent = "";
                //uciCmd("eval");
            /// Is it sending feedback?
            } else if(match = line.match(/^info .*\bdepth (\d+) .*\bnps (\d+)/)) {
                engineStatus.search = 'Depth: ' + match[1] + ' Nps: ' + match[2];
            }

            /// Is it sending feed back with a score?
            if(match = line.match(/^info .*\bscore (\w+) (-?\d+)/)) {
                var score = parseInt(match[2]) * (game.turn() == 'w' ? 1 : -1);
                /// Is it measuring in centipawns?
                if(match[1] == 'cp') {
                    engineStatus.score = (score / 100.0).toFixed(2);
                    eval_b = get_eval(score, 'w', 'cp');
                    //moves_manager.update_eval({ply: ply, type: 'cp', score: score, turn: 'w'});
                /// Did it find a mate?
                } else if(match[1] == 'mate') {
                    engineStatus.score = 'Mate in ' + Math.abs(score);
                    eval_b = get_eval(Math.abs(score), 'w');
                    //moves_manager.update_eval({ply: ply, score: Math.abs(score), turn: 'w'});
                }

                /// Is the score bounded?
                if(match = line.match(/\b(upper|lower)bound\b/)) {
                    engineStatus.score = ((match[1] == 'upper') == (game.turn() == 'w') ? '<= ' : '>= ') + engineStatus.score
                }
            }
        }
        displayStatus();
    };

    function on_message(event){
      var line,
          ply = moves_history.length;
      console.log("white " + ply);

      if (event && typeof event === "object") {
          line = event.data;
      } else {
          line = event;
      }
      //console.log("Reply: " + line)
      if(line === 'uciok' || line === 'readyok') {
        return;
      } else {
          var match = line.match(/^bestmove ([a-h][1-8])([a-h][1-8])([qrbn])?/);
          /// Did the AI move?
          if(match) {
              isEngineRunning = false;
              var engine_move = game.move({from: match[1], to: match[2], promotion: match[3]});
              prepareMove(engine_move);
              //uciCmd("eval", evaler)
          /// Is it sending feedback?
        } else if(match = line.match(/^info .*\bdepth (\d+) .*\bnps (\d+)/)) {
            engineStatus.search = 'Depth: ' + match[1] + ' Nps: ' + match[2];
        }

        /// Is it sending feed back with a score?
        if(match = line.match(/^info .*\bscore (\w+) (-?\d+)/)) {
            var score = parseInt(match[2]) * (game.turn() == 'w' ? 1 : -1);
            /// Is it measuring in centipawns?
            if(match[1] == 'cp') {
                engineStatus.score = (score / 100.0).toFixed(2);
                eval_w = get_eval(score, 'b', 'cp');
                //moves_manager.update_eval({ply: ply, type: 'cp', score: score, turn: 'b'});
            /// Did it find a mate?
            } else if(match[1] == 'mate') {
                engineStatus.score = 'Mate in ' + Math.abs(score);
                eval_w = get_eval(Math.abs(score), 'b');
                //moves_manager.update_eval({ply: ply, score: Math.abs(score), turn: 'b'});
            }

            /// Is the score bounded?
            if(match = line.match(/\b(upper|lower)bound\b/)) {
                engineStatus.score = ((match[1] == 'upper') == (game.turn() == 'w') ? '<= ' : '>= ') + engineStatus.score
            }
        }
      }
    }

    function uciCmd(cmd, which) {
        //console.log("UCI: " + cmd);

        (which || engine).postMessage(cmd);
    }

    uciCmd('uci');

    ///TODO: Eval starting posistions. I suppose the starting positions could be different in different chess varients.

    function displayStatus() {
        var status = 'Engine: ';
        if(!engineStatus.engineLoaded) {
            status += 'loading...';
        } else if(!engineStatus.engineReady) {
            status += 'loaded...';
        } else {
            status += 'ready.';
        }

        if(engineStatus.search) {
            status += '<br>' + engineStatus.search;
            if(engineStatus.score) {
                status += (engineStatus.score.substr(0, 4) === "Mate" ? " " : ' Score: ') + engineStatus.score;
            }
        }
        $('#engineStatus').html(status);
    }

    /*function displayClock(color, t) {
        var isRunning = false;
        if(time.startTime > 0 && color == time.clockColor) {
            t = Math.max(0, t + time.startTime - Date.now());
            isRunning = true;
        }
        var id = color == playerColor ? '#time2' : '#time1';
        var sec = Math.ceil(t / 1000);
        var min = Math.floor(sec / 60);
        sec -= min * 60;
        var hours = Math.floor(min / 60);
        min -= hours * 60;
        var display = hours + ':' + ('0' + min).slice(-2) + ':' + ('0' + sec).slice(-2);
        if(isRunning) {
            display += sec & 1 ? ' <--' : ' <-';
        }
        $(id).text(display);
    }

    function updateClock() {
        displayClock('white', time.wtime);
        displayClock('black', time.btime);
    }

    function clockTick() {
        updateClock();
        var t = (time.clockColor == 'white' ? time.wtime : time.btime) + time.startTime - Date.now();
        var timeToNextSecond = (t % 1000) + 1;
        clockTimeoutID = setTimeout(clockTick, timeToNextSecond);
    }

    function stopClock() {
        if(clockTimeoutID !== null) {
            clearTimeout(clockTimeoutID);
            clockTimeoutID = null;
        }
        if(time.startTime > 0) {
            var elapsed = Date.now() - time.startTime;
            time.startTime = null;
            if(time.clockColor == 'white') {
                time.wtime = Math.max(0, time.wtime - elapsed);
            } else {
                time.btime = Math.max(0, time.btime - elapsed);
            }
        }
    }

    function startClock() {
        if(game.turn() == 'w') {
            time.wtime += time.winc;
            time.clockColor = 'white';
        } else {
            time.btime += time.binc;
            time.clockColor = 'black';
        }
        time.startTime = Date.now();
        clockTick();
    }*/

    function get_moves(){
        var moves = '';
        var history = game.history({verbose: true});

        for(var i = 0; i < history.length; ++i) {
            var move = history[i];
            moves += ' ' + move.from + move.to + (move.promotion ? move.promotion : '');
        }

        return moves;
    }

    function prepareMove(move) {
        //stopClock();
        if (move && move.san){
          // append move.san to move list
          moves_history.push({move: move.san, turn: move.color, pos: 'position fen ' + game.fen(), color: move.color});
          var ply = moves_history.length;
          if (game.in_checkmate()){
            if (move.color === 'w'){
              eval_w = '1-0';
            } else {
              eval_b = '0-1';
            }
          }
          moves_manager.add_move({color: move.color, san: move.san, time: '', eval: move.color === 'w' ? eval_w: eval_b, ply: ply - 1, scoll_to_bottom: true});
        }
        //$('#pgn').text(game.pgn());
        board.position(game.fen());
        //updateClock();
        var turn = game.turn() === 'w' ? 'white' : 'black';
        if(!game.game_over()) {
            if(turn == 'white' && playerColor === 'computer'){
              uciCmd('position startpos moves' + get_moves(), engine_other);
              //uciCmd('position startpos moves' + get_moves(), evaler);
              //evaluation_el.textContent = "";
              //uciCmd("eval", evaler);

              //if (time && time.wtime) {
              //    uciCmd("go " + (time.depth ? "depth " + time.depth : "") + " wtime " + time.wtime + " winc " + time.winc + " btime " + time.btime + " binc " + time.binc);
              //} else {
              uciCmd("go " + (time.depth ? "depth " + (time.depth) : ""), engine_other);
              //}
              isEngineRunning = true;
            } else if (turn != playerColor) {
              uciCmd('position startpos moves' + get_moves());
              //uciCmd('position startpos moves' + get_moves(), evaler);
              //evaluation_el.textContent = "";
              //uciCmd("eval", evaler);

              //if (time && time.wtime) {
              //    uciCmd("go " + (time.depth ? "depth " + time.depth : "") + " wtime " + time.wtime + " winc " + time.winc + " btime " + time.btime + " binc " + time.binc);
              //} else {
              uciCmd("go " + (time.depth ? "depth " + time.depth : ""));
              //}
              isEngineRunning = true;
            }
            // if(game.history().length >= 2 && !time.depth && !time.nodes) {
            //     startClock();
            // }
        } else {
            if (game.game_over()) {
                window.setTimeout(function(){
                  announced_game_over = true;
                  alert("Game Over");
                },1000);
            }
        }
    }

    var onDrop = function(source, target) {
      // see if the move is legal
      var move = game.move({
        from: source,
        to: target,
        promotion: document.getElementById("promote").value
      });

      // illegal move
      if (move === null) return 'snapback';

      prepareMove(move);
    };

    // update the board position after the piece snap
    // for castling, en passant, pawn promotion
    var onSnapEnd = function() {
      board.position(game.fen());
    };

    var cfg = {
        showErrors: true,
        draggable: true,
        position: 'start',
        onDragStart: onDragStart,
        onDrop: onDrop,
        onSnapEnd: onSnapEnd
    };

    board = new ChessBoard('board', cfg);

    return {
        reset: function() {
            game.reset();
            moves_manager.reset_moves();
            moves_history = [];
            uciCmd('setoption name Contempt value 0');
            //uciCmd('setoption name Skill Level value 20');
            this.setSkillLevel(1);
            //uciCmd('setoption name King Safety value 0'); /// Agressive 100 (it's now symetric)
        },
        loadPgn: function(pgn) { game.load_pgn(pgn); },
        setPlayer: function(player) {
            playerColor = player;
            if (player === 'white' || player === 'black') {
              board.orientation(playerColor);
              if (engine_other){
                engine_other.terminate();
                engine_other = undefined;
              }
            } else {
              board.orientation('white');
              engine_other = new Worker('javascripts/stockfish.js');
              engine_other.onmessage = on_message;
            }

        },
        setSkillLevel: function(skill) {
            var max_err,
                err_prob,
                difficulty_slider;

            if (skill < 1) {
                skill = 1;
            }
            if (skill > 20) {
                skill = 20;
            }

            time.level = skill;

            /// Change thinking depth allowance.
            // if (skill < 5) {
            //     time.depth = "1";
            // } else if (skill < 10) {
            //     time.depth = "2";
            // } else if (skill < 15) {
            //     time.depth = "3";
            // } else {
                /// Let the engine decide.
            time.depth = skill;
            //}

            uciCmd('setoption name Skill Level value 18');
            uciCmd('setoption name Contempt value 100');
            if (engine_other){
              uciCmd('setoption name Skill Level value 18', engine_other);
              uciCmd('setoption name Contempt value 0', engine_other);
            }

            ///NOTE: Stockfish level 20 does not make errors (intentially), so these numbers have no effect on level 20.
            /// Level 0 starts at 1
            //err_prob = Math.round(5);
            /// Level 0 starts at 10
            //max_err = Math.round((20 - skill) / 4);

            uciCmd('setoption name Skill Level Maximum Error value 2');
            //uciCmd('setoption name Skill Level Probability value ' + err_prob);
        },
        setTime: function(baseTime, inc) {
            time = { wtime: baseTime * 1000, btime: baseTime * 1000, winc: inc * 1000, binc: inc * 1000 };
        },
        setDepth: function(depth) {
            time = { depth: depth };
        },
        setNodes: function(nodes) {
            time = { nodes: nodes };
        },
        setContempt: function(contempt) {
            uciCmd('setoption name Contempt value ' + contempt);
        },
        setAggressiveness: function(value) {
            uciCmd('setoption name Aggressiveness value ' + value);
        },
        setDisplayScore: function() {
            displayStatus();
        },
        start: function() {
            uciCmd('ucinewgame');
            uciCmd('isready');

            if (engine_other){
              uciCmd('ucinewgame', engine_other);
              uciCmd('isready', engine_other);
            }
            engineStatus.engineReady = false;
            engineStatus.search = null;
            //moves_history = [{turn: 'w', pos: 'position fen rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'}];
            displayStatus();
            prepareMove();
            announced_game_over = false;
        },
        undo: function() {
          if(isEngineRunning)
            return false;
          game.undo();
          game.undo();
          engineStatus.search = null;
          displayStatus();
          prepareMove();
          return true;
        }
    };
}

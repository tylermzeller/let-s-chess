function make_moves(parent, height_parent){
    "use strict";

    var moves_elm = $(document.createElement('div')).addClass('moves-list'),
        container = $(document.createElement('div')).addClass('moves-list-wrapper'),
        rows,
        plys = [],
        track_row,
        offset_height,
        selected_id;

    function clean_san(san) {
        /// \u2011 is a non-breaking hyphen (useful for O-O-O).
        return san.replace(/-/g, "\u2011");
    }

    function format_move_time(time){
        var res,
            sec,
            min,
            hour,
            day;

        time = parseFloat(time);

        if (time < 0) {
            time = 0;
        }

        if (time < 100) { /// Less than 100ms
            res = time + "ms";
        } else if (time < 1000) { /// Less than 1 sec
            res = ((Math.round(time / 100)) / 10) + "s";
        } else if (time < 60000) { /// Less than 1 minute
            res = Math.round(time / 1000) + "s";
        } else if (time < 3600000) { /// Less than 1 hour
            /// Always floor since we don't want to round to 60.
            sec = Math.floor((time % 60000) / 1000);
            min = Math.floor(time / 60000);
            res = min + "m" + sec + "s";
        } else if (time < 86400000) { /// Less than 1 day
            /// Always floor since we don't want to round to 60.
            sec  = Math.floor((time % 60000) / 1000);
            hour = Math.floor(time / 60000);
            min  = Math.floor(hour % 60);
            hour = (hour - min) / 60;

            res = hour + "h" + min + "m" + sec + "s";

        } else { /// Days
            ///NOTE: NaN is always falsey, so it will come here. We check this here so that we don't need to waste time checking eariler.
            if (isNaN(time)) {
                return "Error";
            }
            /// Always floor since we don't want to round to 60.
            sec  = Math.floor((time % 60000) / 1000);
            hour = Math.floor(time / 60000);
            min  = Math.floor(hour % 60);
            hour = (hour - min) / 60;
            day = Math.floor(hour / 24);
            hour = hour % 24;

            res = day + "d" + hour + "h" + min + "m" + sec + "s";
        }

        return res;
    }

    function add_move(options){
        var cur_row,
            even_odd,
            clickable_cell,
            extra_ply;

        if (plys[options.ply]) {
            //console.log("TODO: Select " + options.ply);
            return;
        }

        /// If we start with black, we need to add an extra ply to get to the correct row.
        extra_ply = (plys[0] ? plys[0].color : options.color) === "b" ? 1 : 0;
        cur_row = Math.floor((options.ply + extra_ply) / 2);

        even_odd = cur_row % 2 ? "-even" : "-odd";
        clickable_cell = options.onclick ? " move-click" : "";

        plys[options.ply] = {
            san: options.san,
            color: options.color,
            time: options.time,
            id: options.id,
            num_click: options.num_click,
            san_el:  $(document.createElement('div')).addClass('move-cell move-san move' + options.color + ' move-row' + even_odd + clickable_cell).text(clean_san(options.san)), //G.cde("div", {c: "moveCell moveSAN move"  + options.color + " moveRow" + even_odd + clickable_cell, t: clean_san(options.san)}, {click: options.onclick}),
            eval_el: $(document.createElement('div')).addClass('move-cell move-eval move' + options.color + ' move-row' + even_odd).text(options.eval),//G.cde("div", {c: "moveCell moveEval move" + options.color + " moveRow" + even_odd + clickable_cell, t: "\u00a0"}, {click: options.onclick}), /// \u00a0 is &nbsp;
            time_el: $(document.createElement('div')).addClass('move-cell move-time move' + options.color + ' move-row' + even_odd).text(typeof options.time === 'number' ? format_move_time(options.time) : '\u00a0')//G.cde("div", {c: "moveCell moveTime move" + options.color + " moveRow" + even_odd + clickable_cell, t: typeof options.time === "number" ? format_move_time(options.time) : "\u00a0"}, {click: options.onclick}),
        };

        if (typeof options.pm !== "undefined") {
            plys[options.ply].pm = options.pm;
        }

        if (!options.do_not_display) {
            create_rows(options);
        }
    }

    function create_rows(scoll_to_bottom){
        var cur_row,
            scroll_to_el,
            extra_ply = plys && plys[0] && plys[0].color === 'b' ? 1 : 0; /// If we start with black, we need to add an extra ply to get to the correct row.

        moves_elm.innerHTML = '';

        plys.forEach(function (move_data, ply){
            var need_to_add_placeholders,
                row_num,
                color = move_data.color,
                san = move_data.san,
                time = move_data.time,
                cur_row = Math.floor((ply + extra_ply) / 2),
                even_odd,
                clickable_cell,
                num_events;

            even_odd = cur_row % 2 ? "-even" : "-odd";


            // Placeholders are necessary to keep the table columns the proper width. It's only needed to fill out the first row.
            function add_placeholding_els(){
                var placeholders = [],
                    i,
                    len = 3;

                for (i = 0; i < len; i += 1) {
                    //NOTE: We make it moveSAN to make the ellipse bold.
                    //NOTE: Don't add ellipse on checkmate (unless we're adding the placeholder earlier (i.e., we're black)).
                    placeholders[i] = makeElm('div',
                    {
                      class: 'move-cell move-san move' + (color == 'w' ? 'b' : 'w') + ' move-row' + even_odd,
                      text: i === 0 && (color === "b" || san.slice(-1) !== "#") ? "\u2026" : "\u00a0"
                    }); // \u2026 is ellipse; \u00a0 is non-breaking space.
                    rows[cur_row].row_el.append(placeholders[i]);
                }

                rows[cur_row].placeholders = placeholders;
            }

            if (!rows[cur_row]) {
                need_to_add_placeholders = rows.length === 0;
                clickable_cell = move_data.num_click ? " move-click" : "";
                if (clickable_cell) {
                    num_events = {click: move_data.num_click};
                }
                rows[cur_row] = {
                    w: {},
                    b: {},
                    row_el: makeElm('div', {class: 'move-row'}),
                };
                rows[cur_row].row_el.append(makeElm('div', {class: 'move-num move-row' + even_odd, text: cur_row + 1})); //G.cde("div", {c: "moveNumCell moveRow" + even_odd + clickable_cell, t: (cur_row + 1)}, num_events)
                moves_elm.append(rows[cur_row].row_el);

            } else if (rows[cur_row].placeholders) {
                rows[cur_row].placeholders.forEach(function (el){
                    if (el) {
                        el.remove(); // el is JQuery object
                    }
                });
                delete rows[cur_row].placeholders;
            }

            if (need_to_add_placeholders && color === "b") {
                add_placeholding_els();
                need_to_add_placeholders = false;
            }

            if (move_data.id === selected_id) {
                scroll_to_el = rows[cur_row].row_el;
                move_data.san_el.classList.add('move-selected');
                move_data.eval_el.classList.add('move-selected');
                move_data.time_el.classList.add('move-selected');
            } else {
                move_data.san_el.removeClass('move-selected');
                move_data.eval_el.removeClass('move-selected');
                move_data.time_el.removeClass('move-selected');
            }

            rows[cur_row].row_el.append(move_data.san_el);
            rows[cur_row].row_el.append(move_data.eval_el);
            rows[cur_row].row_el.append(move_data.time_el);

            if (color === "w") {
                add_placeholding_els();
            }

            rows[cur_row][color] = move_data;
        });

        if (scoll_to_bottom) {
          container[0].scrollTop = container[0].scrollHeight;
        } else if (scroll_to_el) {
            scroll_to_row(scroll_to_el);
        }
    }

    function scroll_to_row(el){
        var el_rect = el[0].getBoundingClientRect(),
            container_rect = container[0].getBoundingClientRect(),
            cur_top;

        cur_top = (el_rect.top + window.scrollY) - (container_rect.top + window.scrollY)

        /// Is it not totally visible?
        if (cur_top < 0 || cur_top + el_rect.height > container_rect.height) {
            container[0].scrollTop = (cur_top + container[0].scrollTop) - (container_rect.height / 2) + (el_rect.height / 2);
        }
    }

    function get_move_data_by_id(id){
        var move_data;

        plys.some(function onsome(data)
        {
            if (data.id === id) {
                move_data = data;
                return true; /// break
            }
        });

        return move_data;
    }

    function update_eval(options){
        var move_data,
            display_score;

        if (options.turn === 'b'){
          console.log(plys[options.ply - 2]);
        }

        if (typeof options.ply !== "undefined") {
            move_data = plys[options.ply - 1];

        } else if (typeof options.id !== "undefined") {
            move_data = get_move_data_by_id(options.id);
        }

        if (move_data) {
            if (options.type === "cp") {
                display_score = (options.score / 100).toFixed(2);
            } else if (options.score === 0) {
                if (options.turn === "w") {
                    display_score = "0-1";
                } else {
                    display_score = "1-0";
                }
            } else {
                display_score = "#" + options.score;
            }

            move_data.eval_el[0].textContent = display_score;
        }
    }

    function update_san(options){
        var move_data;

        if (typeof options.ply !== "undefined") {
            move_data = plys[options.ply - 1];
        } else if (typeof options.id !== "undefined") {
            move_data = get_move_data_by_id(options.id);
        }

        if (move_data) {
            move_data.san_el.textContent = clean_san(options.san);
        }
    }


    function reset_moves(){
        moves_elm[0].innerHTML = "";
        rows = [];
        plys = [];
        selected_id = -1;
    }

    function resize(){
        var container_elm = container[0],
            this_box = container_elm.getBoundingClientRect(),
            cell_box,
            old_display = container_elm.style.display;

        //NOTE: We need to hide this for a moment to see what the height of the cell should be.
        //container_elm.style.display = "none";
        cell_box = height_parent[0].getBoundingClientRect();
        container_elm.style.display = old_display;
        container_elm.style.height = "300px";//(cell_box.height - this_box.top) + "px";

        offset_height = container_elm.offsetHeight;
    }

    function destroy(){
        reset_moves();
    }

    function set_highlighted(id, do_not_display){
        selected_id = id;

        if (!do_not_display) {
            create_rows();
        }
    }

    parent.append(container);
    container.append(moves_elm);

    reset_moves();

    return {
        add_move: add_move,
        update_eval: update_eval,
        resize: resize,
        destroy: destroy,
        reset_moves: reset_moves,
        create_rows: create_rows,
        set_highlighted: set_highlighted,
        update_san: update_san,
    };
}

var makeElm = function(name_string, options){
  var elm = $(document.createElement(name_string));

  if (options){
    if (options.class){
      elm.addClass(options.class);
    }

    if (options.text){
      elm.text(options.text);
    }
  }

  return elm;
};

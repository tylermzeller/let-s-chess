function event_manager(){
  var function_map = {};

  return {
    attach: function(name, callback, once){
      var i;
      once = once === undefined ? false : once

      // Should the function be attached to multiple events?
      if (name instanceof Array) {
        for (i = 0; i < name.length; i += 1) {
          // If "once" is an array, then use the elements of the array.
          // If "once" is not an array, then just send the "once" variable each time.
          this.attach(name[i], callback, once instanceof Array ? once[i] : once);
        }
      } else {
        if (typeof callback === "function") {
          
          // Has a function been previously attached to this event? If not, create a function to handle them.
          if (!function_map[name]) {
            function_map[name] = [];
          }

          // Since we may remove events while calling them, it's easiest to store the array in reverse.
          function_map[name].unshift({
            callback: callback,
            once: once
          });
        }
      }
    }, // END attach
    detach: function detach(name, callback, once){
      var i;
      once = once === undefined ? false : once;

      /// Are there multiple events to remove?
      if (name instanceof Array) {
        for (i = name.length - 1; i >= 0; i -= 1) {
            /// If "once" is an array, then use the elements of the array.
            /// If "once" is not an array, then just send the "once" variable each time.
            this.detach(name[i], callback, once instanceof Array ? once[i] : once);
        }
      } else if (function_map[name]) {
        for (i = function_map[name].length - 1; i >= 0; i -= 1) {
            ///NOTE: Both callback and once must match.
            if (function_map[name][i].callback === callback && function_map[name][i].once === once) {
                remove(function_map[name], i);
                /// Since only one event should be removed at a time, we can end now.
                return;
            }
        }
      }
    }, //END detach
    trigger: function trigger(name, e){
      var i,
          stop_propagation;

      /// Does this event have any functions attached to it?
      if (function_map[name]) {
        if (!(e instanceof Object && !(e instanceof Array))) {
          /// If the event object was not specificed, it needs to be created in order to attach stopPropagation() to it.
          e = {};
        }

        /// If an attached function runs this function, it will stop calling other functions.
        e.stopPropagation = function () {
          stop_propagation = true;
        };

        // Execute the functions in reverse order so that we can remove them without throwing the order off.
        for (i = function_map[name].length - 1; i >= 0; i -= 1) {
          ///NOTE: It would be a good idea to use a try/catch to prevent errors in events from preventing the code that called the
          ///      event from firing.  However, there would need to be some sort of error handling. Sending a message back to the
          ///      server would be a good feature.
          /// Check to make sure the function actually exists.
          if (function_map[name][i]) {
              function_map[name][i].callback(e);
          }

          /// Is this function only supposed to be executed once?
          if (!function_map[name][i] || function_map[name][i].once) {
            remove(function_map[name], i);
          }

          /// Was e.stopPropagation() called?
          if (stop_propagation) {
            break;
          }
        }
      }
    },
    to_string: function to_string(string){
      console.log(function_map[string]);
    } // END to_string
  };
}

function remove(array, i){
  var length = array.length;

  /// Handle negative numbers.
  if (i < 0) {
    i = length + i;
  }

  /// If the last element is to be removed, then all we need to do is pop it off.
  if (i === length - 1) {
      array.pop();
  /// If the second to last element is to be removed, we can just pop off the last one and replace the second to last one with it.
  } else if (i === length - 2) {
      if (i >= 0 && i < length) {
          array[i] = array.pop();
      }
  } else {
    /// The first element can be quickly shifted off.
    if (i === 0) {
      array.shift();
    } else if (i > 0) {
      array.splice(i, 1);
    }
  }
}

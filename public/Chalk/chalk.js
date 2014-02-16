(function() {
  window.addEventListener("DOMContentLoaded", function() {
    var activateTool, activeTool, background, body, canvas, chalkboard, close, closeShareWindow, context, count, createPattern, draw, erasePattern, ledge, lightswitch, openShareWindow, output, points, redPattern, setStroke, shade, share, skip, tools, updateOffsets, whitePattern, x, xOffset, y, yOffset;
    body = $("body");
    canvas = $("#canvas");
    chalkboard = $("#chalkboard");
    close = $("#close");
    ledge = $("#ledge");
    lightswitch = $("#lightswitch");
    output = $("#output");
    shade = $("#shade");
    share = $("#share");
    canvas.attr("width", chalkboard.width());
    canvas.attr("height", chalkboard.height());
    xOffset = (yOffset = 0);
    context = canvas.get(0).getContext("2d");
    context.lineWidth = 8;
    context.lineCap = "round";
    context.lineJoin = "miter";
    background = new Image();
    background.src = "images/background.jpg";
    background.onload = function() {
      return context.drawImage(background, -128, -129);
    };
    updateOffsets = function() {
      var offsets;
      offsets = chalkboard.offset();
      xOffset = offsets.left;
      return (yOffset = offsets.top);
    };
    window.addEventListener("orientationchange", updateOffsets);
    updateOffsets();
    window.addEventListener("touchmove", function(event) {
      return event.preventDefault();
    });
    /* Tools */
    createPattern = function(name, callback) {
      var image;
      image = new Image();
      image.src = ("images/chalk-tile-" + (name));
      return (image.onload = function() {
        return callback(context.createPattern(image, "repeat"));
      });
    };
    setStroke = function(pattern, width) {
      context.strokeStyle = pattern;
      return (context.lineWidth = width);
    };
    whitePattern = (redPattern = (erasePattern = null));
    createPattern("white.png", function(p) {
      return setStroke(whitePattern = p, 8);
    });
    createPattern("red.png", function(p) {
      return (redPattern = p);
    });
    createPattern("erase.jpg", function(p) {
      return (erasePattern = p);
    });
    tools = ["eraser", "red_chalk", "white_chalk"];
    activeTool = "";
    activateTool = function(tool) {
      var _len, _ref, id, index;
      if (tool === activeTool) {
        return null;
      }
      tools.splice(tools.indexOf(tool), 1);
      tools.push(activeTool = tool);
      _ref = tools;
      for (index = 0, _len = _ref.length; index < _len; index++) {
        id = _ref[index];
        $("#" + (id) + ", #" + (id) + "_tool").css("z-index", index);
      }
      $("#tools div.tool").removeClass("active");
      $("#" + (id) + "_tool").addClass("active");
      switch (tool) {
        case "red_chalk":
          return (context.strokeStyle = setStroke(redPattern, 8));
        case "white_chalk":
          return (context.strokeStyle = setStroke(whitePattern, 8));
        case "eraser":
          return (context.strokeStyle = setStroke(erasePattern, 32));
      }
    };
    activateTool("white_chalk");
    ledge.delegate("a", "click", function(target) {
      return activateTool($(target).attr("id"));
    });
    /* Drawing */
    skip = false;
    count = 0;
    points = [null];
    x = (y = null);
    draw = function(point) {
      var _ref;
      if (point) {
        if (skip) {
          return (skip = false);
        } else {
          context.moveTo(x, y);
          _ref = point;
          x = _ref[0];
          y = _ref[1];
          return context.lineTo(x, y);
        }
      } else {
        return (skip = true);
      }
    };
    canvas.bind("touchstart", function(event) {
      var _ref, touch;
      touch = event.touches[0];
      _ref = [touch.pageX - xOffset, touch.pageY - yOffset];
      x = _ref[0];
      y = _ref[1];
      return event.preventDefault();
    });
    canvas.bind("touchmove", function(event) {
      var touch;
      touch = event.touches[0];
      return points.push([touch.pageX - xOffset, touch.pageY - yOffset]);
    });
    canvas.bind("touchend", function(event) {
      return points.push([x, y], [x, y], null);
    });
    setInterval(function() {
      var start;
      if (!(points.length)) {
        return null;
      }
      start = new Date();
      context.beginPath();
      while (points.length && new Date() - start < 10) {
        draw(points.shift());
      }
      return context.stroke();
    }, 30);
    /* Shade */
    lightswitch.bind("click", function(event) {
      if (body.hasClass("shade")) {
        body.removeClass("shade");
      } else {
        body.addClass("shade");
      }
      return event.preventDefault();
    });
    /* Share */
    openShareWindow = function() {
      share.addClass("active");
      return setTimeout(function() {
        output.attr("src", canvas.get(0).toDataURL());
        return (output.get(0).onload = function() {
          return body.addClass("share");
        });
      }, 10);
    };
    closeShareWindow = function() {
      share.removeClass("active");
      body.removeClass("share");
      output.get(0).onload = null;
      return output.attr("src", "images/chalk-sprites.png");
    };
    share.bind("touchstart", function() {
      return openShareWindow();
    });
    close.bind("click", function(event) {
      closeShareWindow();
      return event.preventDefault();
    });
    return output.bind("touchcancel", function() {
      return setTimeout(closeShareWindow, 50);
    });
  });
}).call(this);

// Generated by CoffeeScript 2.7.0
import {
  g,
  print,
  range,
  scalex,
  scaley
} from './globals.js';

export var Button = class Button {
  constructor(title, help, click) {
    this.title = title;
    this.help = help;
    this.click = click;
    this.active = true;
    this.t = g.tournament;
  }

  draw() {
    textAlign(CENTER, CENTER);
    if (this.title === '') {
      return;
    }
    fill(this.active ? 'yellow' : 'lightgray');
    rect(scalex(this.x), scaley(this.y), scalex(this.w), scaley(this.h));
    fill('black');
    text(this.title, scalex(this.x + this.w / 2), scaley(this.y + this.h / 2));
    textAlign(LEFT, CENTER);
    if (this.inside(mouseX, mouseY)) {
      return text(this.help, 10, scaley(this.y + 3.2 * this.h / 2));
    } else if (mouseY < 20) {
      if (this.title === 'In') {
        return text(`Missing results=${g.calcMissing()} Players=${g.N} Paused=${this.t.paused.length}`, 10, scaley(this.y + 3.2 * this.h / 2)); // else painted many times
      }
    }
  }

  inside(x, y) {
    return (scalex(this.x) <= x && x <= scalex(this.x + this.w)) && (scaley(this.y) <= y && y <= scaley(this.y + this.h));
  }

};

export var spread = function(buttons, letterWidth, y, h) {
  var button, key, results, x;
  x = letterWidth;
  results = [];
  for (key in buttons) {
    button = buttons[key];
    button.x = x;
    button.y = y;
    button.w = (button.title.length + 2) * letterWidth;
    button.h = h;
    if (button.title.length > 0 || key === "ArrowUp") {
      results.push(x += button.w + letterWidth);
    } else {
      results.push(void 0);
    }
  }
  return results;
};

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiYnV0dG9uLmpzIiwic291cmNlUm9vdCI6Ii4uXFwiLCJzb3VyY2VzIjpbImNvZmZlZVxcYnV0dG9uLmNvZmZlZSJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiO0FBQUEsT0FBQTtFQUFTLENBQVQ7RUFBVyxLQUFYO0VBQWlCLEtBQWpCO0VBQXVCLE1BQXZCO0VBQThCLE1BQTlCO0NBQUEsTUFBQTs7QUFFQSxPQUFBLElBQWEsU0FBTixNQUFBLE9BQUE7RUFDTixXQUFjLE1BQUEsTUFBQSxPQUFBLENBQUE7SUFBQyxJQUFDLENBQUE7SUFBTyxJQUFDLENBQUE7SUFBTSxJQUFDLENBQUE7SUFDOUIsSUFBQyxDQUFBLE1BQUQsR0FBVTtJQUNWLElBQUMsQ0FBQSxDQUFELEdBQUssQ0FBQyxDQUFDO0VBRk07O0VBSWQsSUFBTyxDQUFBLENBQUE7SUFDTixTQUFBLENBQVUsTUFBVixFQUFpQixNQUFqQjtJQUNBLElBQUcsSUFBQyxDQUFBLEtBQUQsS0FBVSxFQUFiO0FBQXFCLGFBQXJCOztJQUVBLElBQUEsQ0FBUSxJQUFDLENBQUEsTUFBSixHQUFnQixRQUFoQixHQUE4QixXQUFuQztJQUNBLElBQUEsQ0FBSyxNQUFBLENBQU8sSUFBQyxDQUFBLENBQVIsQ0FBTCxFQUFnQixNQUFBLENBQU8sSUFBQyxDQUFBLENBQVIsQ0FBaEIsRUFBMkIsTUFBQSxDQUFPLElBQUMsQ0FBQSxDQUFSLENBQTNCLEVBQXNDLE1BQUEsQ0FBTyxJQUFDLENBQUEsQ0FBUixDQUF0QztJQUVBLElBQUEsQ0FBSyxPQUFMO0lBQ0EsSUFBQSxDQUFLLElBQUMsQ0FBQSxLQUFOLEVBQVksTUFBQSxDQUFPLElBQUMsQ0FBQSxDQUFELEdBQUcsSUFBQyxDQUFBLENBQUQsR0FBRyxDQUFiLENBQVosRUFBNEIsTUFBQSxDQUFPLElBQUMsQ0FBQSxDQUFELEdBQUcsSUFBQyxDQUFBLENBQUQsR0FBRyxDQUFiLENBQTVCO0lBQ0EsU0FBQSxDQUFVLElBQVYsRUFBZSxNQUFmO0lBQ0EsSUFBRyxJQUFDLENBQUEsTUFBRCxDQUFRLE1BQVIsRUFBZSxNQUFmLENBQUg7YUFDQyxJQUFBLENBQUssSUFBQyxDQUFBLElBQU4sRUFBVyxFQUFYLEVBQWMsTUFBQSxDQUFPLElBQUMsQ0FBQSxDQUFELEdBQUcsR0FBQSxHQUFJLElBQUMsQ0FBQSxDQUFMLEdBQU8sQ0FBakIsQ0FBZCxFQUREO0tBQUEsTUFFSyxJQUFHLE1BQUEsR0FBUyxFQUFaO01BQ0osSUFBRyxJQUFDLENBQUEsS0FBRCxLQUFVLElBQWI7ZUFBdUIsSUFBQSxDQUFLLENBQUEsZ0JBQUEsQ0FBQSxDQUFtQixDQUFDLENBQUMsV0FBRixDQUFBLENBQW5CLENBQUEsU0FBQSxDQUFBLENBQThDLENBQUMsQ0FBQyxDQUFoRCxDQUFBLFFBQUEsQ0FBQSxDQUE0RCxJQUFDLENBQUEsQ0FBQyxDQUFDLE1BQU0sQ0FBQyxNQUF0RSxDQUFBLENBQUwsRUFBb0YsRUFBcEYsRUFBdUYsTUFBQSxDQUFPLElBQUMsQ0FBQSxDQUFELEdBQUcsR0FBQSxHQUFJLElBQUMsQ0FBQSxDQUFMLEdBQU8sQ0FBakIsQ0FBdkYsRUFBdkI7T0FESTs7RUFaQzs7RUFlUCxNQUFTLENBQUMsQ0FBRCxFQUFHLENBQUgsQ0FBQTtXQUFTLENBQUEsTUFBQSxDQUFPLElBQUMsQ0FBQSxDQUFSLENBQUEsSUFBYyxDQUFkLElBQWMsQ0FBZCxJQUFtQixNQUFBLENBQU8sSUFBQyxDQUFBLENBQUQsR0FBSyxJQUFDLENBQUEsQ0FBYixDQUFuQixDQUFBLElBQXVDLENBQUEsTUFBQSxDQUFPLElBQUMsQ0FBQSxDQUFSLENBQUEsSUFBYyxDQUFkLElBQWMsQ0FBZCxJQUFtQixNQUFBLENBQU8sSUFBQyxDQUFBLENBQUQsR0FBSyxJQUFDLENBQUEsQ0FBYixDQUFuQjtFQUFoRDs7QUFwQkg7O0FBc0JQLE9BQUEsSUFBTyxNQUFBLEdBQVMsUUFBQSxDQUFDLE9BQUQsRUFBVSxXQUFWLEVBQXVCLENBQXZCLEVBQTBCLENBQTFCLENBQUE7QUFDaEIsTUFBQSxNQUFBLEVBQUEsR0FBQSxFQUFBLE9BQUEsRUFBQTtFQUFDLENBQUEsR0FBSTtBQUNKO0VBQUEsS0FBQSxjQUFBOztJQUNDLE1BQU0sQ0FBQyxDQUFQLEdBQVc7SUFDWCxNQUFNLENBQUMsQ0FBUCxHQUFXO0lBQ1gsTUFBTSxDQUFDLENBQVAsR0FBVyxDQUFDLE1BQU0sQ0FBQyxLQUFLLENBQUMsTUFBYixHQUFzQixDQUF2QixDQUFBLEdBQTRCO0lBQ3ZDLE1BQU0sQ0FBQyxDQUFQLEdBQVc7SUFDWCxJQUFHLE1BQU0sQ0FBQyxLQUFLLENBQUMsTUFBYixHQUFzQixDQUF0QixJQUEyQixHQUFBLEtBQU8sU0FBckM7bUJBQW9ELENBQUEsSUFBSyxNQUFNLENBQUMsQ0FBUCxHQUFXLGFBQXBFO0tBQUEsTUFBQTsyQkFBQTs7RUFMRCxDQUFBOztBQUZlIiwic291cmNlc0NvbnRlbnQiOlsiaW1wb3J0IHsgZyxwcmludCxyYW5nZSxzY2FsZXgsc2NhbGV5IH0gZnJvbSAnLi9nbG9iYWxzLmpzJyBcclxuXHJcbmV4cG9ydCBjbGFzcyBCdXR0b25cclxuXHRjb25zdHJ1Y3RvciA6IChAdGl0bGUsIEBoZWxwLCBAY2xpY2spIC0+IFxyXG5cdFx0QGFjdGl2ZSA9IHRydWVcclxuXHRcdEB0ID0gZy50b3VybmFtZW50XHJcblxyXG5cdGRyYXcgOiAtPlxyXG5cdFx0dGV4dEFsaWduIENFTlRFUixDRU5URVJcclxuXHRcdGlmIEB0aXRsZSA9PSAnJyB0aGVuIHJldHVyblxyXG5cclxuXHRcdGZpbGwgaWYgQGFjdGl2ZSB0aGVuICd5ZWxsb3cnIGVsc2UgJ2xpZ2h0Z3JheSdcclxuXHRcdHJlY3Qgc2NhbGV4KEB4KSxzY2FsZXkoQHkpLHNjYWxleChAdyksc2NhbGV5KEBoKVxyXG5cclxuXHRcdGZpbGwgJ2JsYWNrJ1xyXG5cdFx0dGV4dCBAdGl0bGUsc2NhbGV4KEB4K0B3LzIpLHNjYWxleShAeStAaC8yKVxyXG5cdFx0dGV4dEFsaWduIExFRlQsQ0VOVEVSXHJcblx0XHRpZiBAaW5zaWRlIG1vdXNlWCxtb3VzZVlcclxuXHRcdFx0dGV4dCBAaGVscCwxMCxzY2FsZXkoQHkrMy4yKkBoLzIpXHJcblx0XHRlbHNlIGlmIG1vdXNlWSA8IDIwXHJcblx0XHRcdGlmIEB0aXRsZSA9PSAnSW4nIHRoZW4gdGV4dCBcIk1pc3NpbmcgcmVzdWx0cz0je2cuY2FsY01pc3NpbmcoKX0gUGxheWVycz0je2cuTn0gUGF1c2VkPSN7QHQucGF1c2VkLmxlbmd0aH1cIiwxMCxzY2FsZXkoQHkrMy4yKkBoLzIpICMgZWxzZSBwYWludGVkIG1hbnkgdGltZXNcclxuXHJcblx0aW5zaWRlIDogKHgseSkgLT4gc2NhbGV4KEB4KSA8PSB4IDw9IHNjYWxleChAeCArIEB3KSBhbmQgc2NhbGV5KEB5KSA8PSB5IDw9IHNjYWxleShAeSArIEBoKVxyXG5cclxuZXhwb3J0IHNwcmVhZCA9IChidXR0b25zLCBsZXR0ZXJXaWR0aCwgeSwgaCkgLT5cclxuXHR4ID0gbGV0dGVyV2lkdGhcclxuXHRmb3Iga2V5LGJ1dHRvbiBvZiBidXR0b25zXHJcblx0XHRidXR0b24ueCA9IHhcclxuXHRcdGJ1dHRvbi55ID0geVxyXG5cdFx0YnV0dG9uLncgPSAoYnV0dG9uLnRpdGxlLmxlbmd0aCArIDIpICogbGV0dGVyV2lkdGhcclxuXHRcdGJ1dHRvbi5oID0gaFxyXG5cdFx0aWYgYnV0dG9uLnRpdGxlLmxlbmd0aCA+IDAgb3Iga2V5ID09IFwiQXJyb3dVcFwiIHRoZW4geCArPSBidXR0b24udyArIGxldHRlcldpZHRoXHJcbiJdfQ==
//# sourceURL=c:\github\FairPair\coffee\button.coffee
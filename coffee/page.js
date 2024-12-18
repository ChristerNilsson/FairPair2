// Generated by CoffeeScript 2.7.0
import {
  g,
  print,
  range,
  scalex,
  scaley
} from './globals.js';

import {
  Button,
  spread
} from './button.js';

import {
  Lista
} from './lista.js';

export var Page = class Page {
  constructor() {
    this.HELP = "A = Active";
    this.buttons = {};
    // @buttons.s = new Button 'Standings', 'S = Standings', () => g.setState g.STANDINGS
    // @buttons.t = new Button 'Tables',    'T = Tables',    () => g.setState g.TABLES
    // @buttons.n = new Button 'Names',     'N = Names',     () => g.setState g.NAMES
    // @buttons.a = new Button 'Active',    'A = Active',    () => g.setState g.ACTIVE
    this.buttons.ArrowUp = new Button('', '', () => {
      return this.lista.ArrowUp();
    });
    this.buttons.ArrowDown = new Button('', '', () => {
      return this.lista.ArrowDown();
    });
    this.buttons.PageUp = new Button('', '', () => {
      return this.lista.PageUp();
    });
    this.buttons.PageDown = new Button('', '', () => {
      return this.lista.PageDown();
    });
    this.buttons.Home = new Button('', '', () => {
      return this.lista.Home();
    });
    this.buttons.End = new Button('', '', () => {
      return this.lista.End();
    });
    this.buttons.i = new Button('In', 'I = zoom In', () => {
      return g.zoomIn(Math.floor(g.N / 2));
    });
    this.buttons.o = new Button('Out', 'O = zoom Out', () => {
      return g.zoomOut(Math.floor(g.N / 2));
    });
    this.t = g.tournament;
    this.y = 1.3;
    this.h = 1;
    this.lista = new Lista();
  }

  // mouseMoved : ->
  showHeader(round) {
    var s, y;
    y = 0.6;
    textAlign(LEFT, CENTER);
    s = '';
    s += g.txtT(`${this.t.title} ${this.t.datum}`, 30, LEFT);
    s += g.txtT(`${g.message}`, 30, CENTER);
    s += g.txtT(`${this.t.round}`, 24, CENTER);
    return text(s, 10, scaley(y));
  }

  txt(value, x, y, align = null, color = null) {
    push();
    if (align) {
      textAlign(align, CENTER);
    }
    if (color) {
      fill(color);
    }
    text(value, x, y);
    return pop();
  }

};

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoicGFnZS5qcyIsInNvdXJjZVJvb3QiOiIuLlxcIiwic291cmNlcyI6WyJjb2ZmZWVcXHBhZ2UuY29mZmVlIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7QUFBQSxPQUFBO0VBQVMsQ0FBVDtFQUFXLEtBQVg7RUFBaUIsS0FBakI7RUFBdUIsTUFBdkI7RUFBOEIsTUFBOUI7Q0FBQSxNQUFBOztBQUNBLE9BQUE7RUFBUyxNQUFUO0VBQWdCLE1BQWhCO0NBQUEsTUFBQTs7QUFDQSxPQUFBO0VBQVMsS0FBVDtDQUFBLE1BQUE7O0FBRUEsT0FBQSxJQUFhLE9BQU4sTUFBQSxLQUFBO0VBRU4sV0FBYyxDQUFBLENBQUE7SUFFYixJQUFDLENBQUEsSUFBRCxHQUFRO0lBQ1IsSUFBQyxDQUFBLE9BQUQsR0FBVyxDQUFBLEVBRGI7Ozs7O0lBUUUsSUFBQyxDQUFBLE9BQU8sQ0FBQyxPQUFULEdBQW1CLElBQUksTUFBSixDQUFXLEVBQVgsRUFBZSxFQUFmLEVBQW1CLENBQUEsQ0FBQSxHQUFBO2FBQU0sSUFBQyxDQUFBLEtBQUssQ0FBQyxPQUFQLENBQUE7SUFBTixDQUFuQjtJQUNuQixJQUFDLENBQUEsT0FBTyxDQUFDLFNBQVQsR0FBcUIsSUFBSSxNQUFKLENBQVcsRUFBWCxFQUFjLEVBQWQsRUFBa0IsQ0FBQSxDQUFBLEdBQUE7YUFBTSxJQUFDLENBQUEsS0FBSyxDQUFDLFNBQVAsQ0FBQTtJQUFOLENBQWxCO0lBRXJCLElBQUMsQ0FBQSxPQUFPLENBQUMsTUFBVCxHQUFrQixJQUFJLE1BQUosQ0FBVyxFQUFYLEVBQWUsRUFBZixFQUFtQixDQUFBLENBQUEsR0FBQTthQUFNLElBQUMsQ0FBQSxLQUFLLENBQUMsTUFBUCxDQUFBO0lBQU4sQ0FBbkI7SUFDbEIsSUFBQyxDQUFBLE9BQU8sQ0FBQyxRQUFULEdBQW9CLElBQUksTUFBSixDQUFXLEVBQVgsRUFBYyxFQUFkLEVBQWtCLENBQUEsQ0FBQSxHQUFBO2FBQU0sSUFBQyxDQUFBLEtBQUssQ0FBQyxRQUFQLENBQUE7SUFBTixDQUFsQjtJQUVwQixJQUFDLENBQUEsT0FBTyxDQUFDLElBQVQsR0FBZ0IsSUFBSSxNQUFKLENBQVcsRUFBWCxFQUFlLEVBQWYsRUFBbUIsQ0FBQSxDQUFBLEdBQUE7YUFBTSxJQUFDLENBQUEsS0FBSyxDQUFDLElBQVAsQ0FBQTtJQUFOLENBQW5CO0lBQ2hCLElBQUMsQ0FBQSxPQUFPLENBQUMsR0FBVCxHQUFlLElBQUksTUFBSixDQUFXLEVBQVgsRUFBYyxFQUFkLEVBQWtCLENBQUEsQ0FBQSxHQUFBO2FBQU0sSUFBQyxDQUFBLEtBQUssQ0FBQyxHQUFQLENBQUE7SUFBTixDQUFsQjtJQUVmLElBQUMsQ0FBQSxPQUFPLENBQUMsQ0FBVCxHQUFhLElBQUksTUFBSixDQUFXLElBQVgsRUFBaUIsYUFBakIsRUFBZ0MsQ0FBQSxDQUFBLEdBQUE7YUFBTSxDQUFDLENBQUMsTUFBRixZQUFTLENBQUMsQ0FBQyxJQUFHLEVBQWQ7SUFBTixDQUFoQztJQUNiLElBQUMsQ0FBQSxPQUFPLENBQUMsQ0FBVCxHQUFhLElBQUksTUFBSixDQUFXLEtBQVgsRUFBa0IsY0FBbEIsRUFBa0MsQ0FBQSxDQUFBLEdBQUE7YUFBTSxDQUFDLENBQUMsT0FBRixZQUFVLENBQUMsQ0FBQyxJQUFHLEVBQWY7SUFBTixDQUFsQztJQUViLElBQUMsQ0FBQSxDQUFELEdBQUssQ0FBQyxDQUFDO0lBQ1AsSUFBQyxDQUFBLENBQUQsR0FBSztJQUNMLElBQUMsQ0FBQSxDQUFELEdBQUs7SUFDTCxJQUFDLENBQUEsS0FBRCxHQUFTLElBQUksS0FBSixDQUFBO0VBekJJLENBQWY7OztFQTZCQyxVQUFhLENBQUMsS0FBRCxDQUFBO0FBQ2QsUUFBQSxDQUFBLEVBQUE7SUFBRSxDQUFBLEdBQUk7SUFDSixTQUFBLENBQVUsSUFBVixFQUFlLE1BQWY7SUFDQSxDQUFBLEdBQUk7SUFDSixDQUFBLElBQUssQ0FBQyxDQUFDLElBQUYsQ0FBTyxDQUFBLENBQUEsQ0FBRyxJQUFDLENBQUEsQ0FBQyxDQUFDLEtBQU4sRUFBQSxDQUFBLENBQWUsSUFBQyxDQUFBLENBQUMsQ0FBQyxLQUFsQixDQUFBLENBQVAsRUFBa0MsRUFBbEMsRUFBc0MsSUFBdEM7SUFDTCxDQUFBLElBQUssQ0FBQyxDQUFDLElBQUYsQ0FBTyxDQUFBLENBQUEsQ0FBRyxDQUFDLENBQUMsT0FBTCxDQUFBLENBQVAsRUFBdUIsRUFBdkIsRUFBMkIsTUFBM0I7SUFDTCxDQUFBLElBQUssQ0FBQyxDQUFDLElBQUYsQ0FBTyxDQUFBLENBQUEsQ0FBRyxJQUFDLENBQUEsQ0FBQyxDQUFDLEtBQU4sQ0FBQSxDQUFQLEVBQXNCLEVBQXRCLEVBQTBCLE1BQTFCO1dBQ0wsSUFBQSxDQUFLLENBQUwsRUFBTyxFQUFQLEVBQVUsTUFBQSxDQUFPLENBQVAsQ0FBVjtFQVBZOztFQVNiLEdBQU0sQ0FBQyxLQUFELEVBQVEsQ0FBUixFQUFXLENBQVgsRUFBYyxRQUFNLElBQXBCLEVBQTBCLFFBQU0sSUFBaEMsQ0FBQTtJQUNMLElBQUEsQ0FBQTtJQUNBLElBQUcsS0FBSDtNQUFjLFNBQUEsQ0FBVSxLQUFWLEVBQWlCLE1BQWpCLEVBQWQ7O0lBQ0EsSUFBRyxLQUFIO01BQWMsSUFBQSxDQUFLLEtBQUwsRUFBZDs7SUFDQSxJQUFBLENBQUssS0FBTCxFQUFXLENBQVgsRUFBYSxDQUFiO1dBQ0EsR0FBQSxDQUFBO0VBTEs7O0FBeENBIiwic291cmNlc0NvbnRlbnQiOlsiaW1wb3J0IHsgZyxwcmludCxyYW5nZSxzY2FsZXgsc2NhbGV5IH0gZnJvbSAnLi9nbG9iYWxzLmpzJyBcclxuaW1wb3J0IHsgQnV0dG9uLHNwcmVhZCB9IGZyb20gJy4vYnV0dG9uLmpzJyBcclxuaW1wb3J0IHsgTGlzdGEgfSBmcm9tICcuL2xpc3RhLmpzJyBcclxuXHJcbmV4cG9ydCBjbGFzcyBQYWdlXHJcbiBcclxuXHRjb25zdHJ1Y3RvciA6IC0+XHJcblxyXG5cdFx0QEhFTFAgPSBcIkEgPSBBY3RpdmVcIlxyXG5cdFx0QGJ1dHRvbnMgPSB7fVxyXG5cclxuXHRcdCMgQGJ1dHRvbnMucyA9IG5ldyBCdXR0b24gJ1N0YW5kaW5ncycsICdTID0gU3RhbmRpbmdzJywgKCkgPT4gZy5zZXRTdGF0ZSBnLlNUQU5ESU5HU1xyXG5cdFx0IyBAYnV0dG9ucy50ID0gbmV3IEJ1dHRvbiAnVGFibGVzJywgICAgJ1QgPSBUYWJsZXMnLCAgICAoKSA9PiBnLnNldFN0YXRlIGcuVEFCTEVTXHJcblx0XHQjIEBidXR0b25zLm4gPSBuZXcgQnV0dG9uICdOYW1lcycsICAgICAnTiA9IE5hbWVzJywgICAgICgpID0+IGcuc2V0U3RhdGUgZy5OQU1FU1xyXG5cdFx0IyBAYnV0dG9ucy5hID0gbmV3IEJ1dHRvbiAnQWN0aXZlJywgICAgJ0EgPSBBY3RpdmUnLCAgICAoKSA9PiBnLnNldFN0YXRlIGcuQUNUSVZFXHJcblxyXG5cdFx0QGJ1dHRvbnMuQXJyb3dVcCA9IG5ldyBCdXR0b24gJycsICcnLCAoKSA9PiBAbGlzdGEuQXJyb3dVcCgpXHJcblx0XHRAYnV0dG9ucy5BcnJvd0Rvd24gPSBuZXcgQnV0dG9uICcnLCcnLCAoKSA9PiBAbGlzdGEuQXJyb3dEb3duKClcclxuXHJcblx0XHRAYnV0dG9ucy5QYWdlVXAgPSBuZXcgQnV0dG9uICcnLCAnJywgKCkgPT4gQGxpc3RhLlBhZ2VVcCgpXHJcblx0XHRAYnV0dG9ucy5QYWdlRG93biA9IG5ldyBCdXR0b24gJycsJycsICgpID0+IEBsaXN0YS5QYWdlRG93bigpXHJcblxyXG5cdFx0QGJ1dHRvbnMuSG9tZSA9IG5ldyBCdXR0b24gJycsICcnLCAoKSA9PiBAbGlzdGEuSG9tZSgpXHJcblx0XHRAYnV0dG9ucy5FbmQgPSBuZXcgQnV0dG9uICcnLCcnLCAoKSA9PiBAbGlzdGEuRW5kKClcclxuXHJcblx0XHRAYnV0dG9ucy5pID0gbmV3IEJ1dHRvbiAnSW4nLCAnSSA9IHpvb20gSW4nLCAoKSA9PiBnLnpvb21JbiBnLk4vLzJcclxuXHRcdEBidXR0b25zLm8gPSBuZXcgQnV0dG9uICdPdXQnLCAnTyA9IHpvb20gT3V0JywgKCkgPT4gZy56b29tT3V0IGcuTi8vMlxyXG5cclxuXHRcdEB0ID0gZy50b3VybmFtZW50XHJcblx0XHRAeSA9IDEuM1xyXG5cdFx0QGggPSAxXHJcblx0XHRAbGlzdGEgPSBuZXcgTGlzdGFcclxuXHJcblx0IyBtb3VzZU1vdmVkIDogLT5cclxuXHJcblx0c2hvd0hlYWRlciA6IChyb3VuZCkgLT5cclxuXHRcdHkgPSAwLjZcclxuXHRcdHRleHRBbGlnbiBMRUZULENFTlRFUlxyXG5cdFx0cyA9ICcnXHJcblx0XHRzICs9IGcudHh0VCBcIiN7QHQudGl0bGV9ICN7QHQuZGF0dW19XCIsIDMwLCBMRUZUXHJcblx0XHRzICs9IGcudHh0VCBcIiN7Zy5tZXNzYWdlfVwiLCAzMCwgQ0VOVEVSXHJcblx0XHRzICs9IGcudHh0VCBcIiN7QHQucm91bmR9XCIsIDI0LCBDRU5URVJcclxuXHRcdHRleHQgcywxMCxzY2FsZXkoeSlcclxuXHJcblx0dHh0IDogKHZhbHVlLCB4LCB5LCBhbGlnbj1udWxsLCBjb2xvcj1udWxsKSAtPlxyXG5cdFx0cHVzaCgpXHJcblx0XHRpZiBhbGlnbiB0aGVuIHRleHRBbGlnbiBhbGlnbiwgQ0VOVEVSXHJcblx0XHRpZiBjb2xvciB0aGVuIGZpbGwgY29sb3JcclxuXHRcdHRleHQgdmFsdWUseCx5XHJcblx0XHRwb3AoKSJdfQ==
//# sourceURL=c:\github\FairPair2\coffee\page.coffee
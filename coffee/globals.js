// Generated by CoffeeScript 2.7.0
  // import { Tournament } from './tournament.js' 
var xxx,
  indexOf = [].indexOf;

import {
  Tables
} from './page_tables.js';

import {
  Names
} from './page_names.js';

import {
  Standings
} from './page_standings.js';

import {
  Active
} from './page_active.js';

export var g = {};

//##########################################
g.EXPONENT = 1.01; // 1 or 1.01 (or 2)

g.COLORS = 2; // 2 ej tillåtet, då kan www eller bbb uppstå.


//##########################################
export var print = console.log;

export var range = _.range;

export var scalex = function(x) {
  return x * g.ZOOM[g.state] / 20;
};

export var scaley = function(y) {
  return y * g.ZOOM[g.state];
};

g.seed = 0;

export var random = function() {
  return (((Math.sin(g.seed++) / 2 + 0.5) * 10000) % 100) / 100;
};

export var wrap = function(s) {
  return `(${s})`;
};

g.BYE = -1;

g.PAUSE = -2;

export var SEPARATOR = '!';

g.TABLES = 0;

g.NAMES = 1;

g.STANDINGS = 2;

g.ACTIVE = 3;

g.pages = [];

g.message = "";

g.F = function(diff) {
  return 1 / (1 + pow(10, -diff / 400));
};

g.showType = function(a) {
  if (typeof a === 'string') {
    return `'${a}'`;
  } else {
    return a;
  }
};

export var assert = function(a, b) {
  if (!_.isEqual(a, b)) {
    return print(`Assert failure: ${JSON.stringify(a)} != ${JSON.stringify(b)}`);
  }
};

g.ok = function(a, b) {
  var ref;
  
  // if g.tournament.round < 7
  return a.id !== b.id && (ref = a.id, indexOf.call(b.opp, ref) < 0) && abs(a.balans() + b.balans()) <= 2;
};

// else
// 	a.id != b.id and a.id not in b.opp and abs(a.balans() + b.balans()) <= 2 #1

// g.ok = (a,b) -> 
// 	mand = a.mandatory() + b.mandatory()
// 	a.id != b.id and a.id not in b.opp and mand != "bb" and mand != "ww"
g.other = function(col) {
  if (col === 'b') {
    return 'w';
  } else {
    return 'b';
  }
};

g.myRound = function(x, decs) {
  return x.toFixed(decs);
};

assert("2.0", g.myRound(1.99, 1));

assert("0.6", g.myRound(0.61, 1));

g.ints2strings = function(ints) {
  return `${ints}`;
};

assert("1,2,3", g.ints2strings([1, 2, 3]));

assert("1", g.ints2strings([1]));

assert("", g.ints2strings([]));

g.res2string = function(ints) {
  var i;
  return ((function() {
    var j, len, results;
    results = [];
    for (j = 0, len = ints.length; j < len; j++) {
      i = ints[j];
      results.push(i.toString());
    }
    return results;
  })()).join('');
};

assert("123", g.res2string([1, 2, 3]));

assert("1", g.res2string([1]));

assert("", g.res2string([]));

g.zoomIn = function(n) {
  return g.ZOOM[g.state]++;
};

g.zoomOut = function(n) {
  return g.ZOOM[g.state]--;
};

g.setState = function(newState) {
  if (g.tournament.round > 0) {
    return g.state = newState;
  }
};

g.invert = function(arr) {
  var i, j, len, ref, res;
  res = [];
  ref = range(arr.length);
  for (j = 0, len = ref.length; j < len; j++) {
    i = ref[j];
    res[arr[i]] = i;
  }
  return res;
};

assert([0, 1, 2, 3], g.invert([0, 1, 2, 3]));

assert([3, 2, 0, 1], g.invert([2, 3, 1, 0]));

assert([2, 3, 1, 0], g.invert(g.invert([2, 3, 1, 0])));

xxx = [[2, 1], [12, 2], [12, 1], [3, 4]];

xxx.sort(function(a, b) {
  var diff;
  diff = a[0] - b[0];
  if (diff === 0) {
    return a[1] - b[1];
  } else {
    return diff;
  }
});

assert([[2, 1], [3, 4], [12, 1], [12, 2]], xxx);

assert(true, [2] > [12]);

assert(true, "2" > "12");

assert(false, 2 > 12);

// xxx = [[2,1],[12,2],[12,1],[3,4]]
// assert [[2,1],[12,1],[12,2],[3,4]], _.sortBy(xxx, (x) -> [x[0],x[1]])
// assert [[3,4],[2,1],[12,1],[12,2]], _.sortBy(xxx, (x) -> -x[0])
// assert [[2,1],[12,1],[3,4],[12,2]], _.sortBy(xxx, (x) -> x[1])
// assert [[3,4],[12,1],[2,1],[12,2]], _.sortBy(xxx, (x) -> -x[1])
g.calcMissing = function() {
  var j, len, missing, p, ref;
  missing = 0;
  ref = g.tournament.playersByID;
  for (j = 0, len = ref.length; j < len; j++) {
    p = ref[j];
    if (!p.active) {
      continue;
    }
    if (g.BYE === _.last(p.opp)) {
      continue;
    }
    if (p.res.length < p.col.length) {
      missing++;
    }
  }
  // g.message = "#{missing//2} results missing"
  return Math.floor(missing / 2);
};

g.sum = function(s) {
  var item, j, len, res;
  res = 0;
  for (j = 0, len = s.length; j < len; j++) {
    item = s[j];
    res += parseFloat(item);
  }
  return res;
};

assert(6, g.sum('012012'));

g.sumNumbers = function(arr) {
  var item, j, len, res;
  // print 'sumNumbers',arr
  res = 0;
  for (j = 0, len = arr.length; j < len; j++) {
    item = arr[j];
    res += item;
  }
  return res;
};

assert(15, g.sumNumbers([1, 2, 3, 4, 5]));

g.txtT = function(value, w, align = CENTER) {
  var diff, lt, res, rt;
  if (value.length > w) {
    value = value.substring(0, w);
  }
  if (value.length < w && align === RIGHT) {
    value = value.padStart(w);
  }
  if (align === LEFT) {
    res = value + _.repeat(' ', w - value.length);
  }
  if (align === RIGHT) {
    res = _.repeat(' ', w - value.length) + value;
  }
  if (align === CENTER) {
    diff = w - value.length;
    lt = _.repeat(' ', Math.floor((1 + diff) / 2));
    rt = _.repeat(' ', Math.floor(diff / 2));
    res = lt + value + rt;
  }
  return res;
};

g.prBth = function(score) {
  return `${'0½1'[score]}-${'1½0'[score]}`;
};

g.prBoth = function(score) {
  return ` ${'0½1'[score]} - ${'1½0'[score]} `;
};

//##########################

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiZ2xvYmFscy5qcyIsInNvdXJjZVJvb3QiOiIuLlxcIiwic291cmNlcyI6WyJjb2ZmZWVcXGdsb2JhbHMuY29mZmVlIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7QUFBK0M7QUFBQSxJQUFBLEdBQUE7RUFBQTs7QUFDL0MsT0FBQTtFQUFTLE1BQVQ7Q0FBQSxNQUFBOztBQUNBLE9BQUE7RUFBUyxLQUFUO0NBQUEsTUFBQTs7QUFDQSxPQUFBO0VBQVMsU0FBVDtDQUFBLE1BQUE7O0FBQ0EsT0FBQTtFQUFTLE1BQVQ7Q0FBQSxNQUFBOztBQUVBLE9BQUEsSUFBTyxDQUFBLEdBQUksQ0FBQSxFQU5vQzs7O0FBVS9DLENBQUMsQ0FBQyxRQUFGLEdBQWEsS0FWa0M7O0FBVy9DLENBQUMsQ0FBQyxNQUFGLEdBQVcsRUFYb0M7Ozs7QUFlL0MsT0FBQSxJQUFPLEtBQUEsR0FBUSxPQUFPLENBQUM7O0FBQ3ZCLE9BQUEsSUFBTyxLQUFBLEdBQVEsQ0FBQyxDQUFDOztBQUNqQixPQUFBLElBQU8sTUFBQSxHQUFTLFFBQUEsQ0FBQyxDQUFELENBQUE7U0FBTyxDQUFBLEdBQUksQ0FBQyxDQUFDLElBQUksQ0FBQyxDQUFDLENBQUMsS0FBSCxDQUFWLEdBQXNCO0FBQTdCOztBQUNoQixPQUFBLElBQU8sTUFBQSxHQUFTLFFBQUEsQ0FBQyxDQUFELENBQUE7U0FBTyxDQUFBLEdBQUksQ0FBQyxDQUFDLElBQUksQ0FBQyxDQUFDLENBQUMsS0FBSDtBQUFqQjs7QUFFaEIsQ0FBQyxDQUFDLElBQUYsR0FBUzs7QUFDVCxPQUFBLElBQU8sTUFBQSxHQUFTLFFBQUEsQ0FBQSxDQUFBO1NBQUcsQ0FBQyxDQUFDLENBQUMsSUFBSSxDQUFDLEdBQUwsQ0FBUyxDQUFDLENBQUMsSUFBRixFQUFULENBQUEsR0FBbUIsQ0FBbkIsR0FBcUIsR0FBdEIsQ0FBQSxHQUEyQixLQUE1QixDQUFBLEdBQW1DLEdBQXBDLENBQUEsR0FBeUM7QUFBNUM7O0FBRWhCLE9BQUEsSUFBTyxJQUFBLEdBQU8sUUFB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QUFDLEtBQUQsQ0FBQTtTQUFXLENBQUEsQ0FBQSxDQUFHLEtBQUssQ0FBQyxLQUFELENBQVIsQ0FBQSxDQUFBLENBQUEsQ0FBbUIsS0FBSyxDQUFDLEtBQUQsQ0FBeEIsQ0FBQTtBQUFYOztBQUNWLENBQUMsQ0FBQyxNQUFGLEdBQVcsUUFBQSxDQUFDLEtBQUQsQ0FBQTtTQUFXLEVBQUEsQ0FBQSxDQUFJLEtBQUssQ0FBQyxLQUFELENBQVQsQ0FBQSxHQUFBLENBQUEsQ0FBc0IsS0FBSyxDQUFDLEtBQUQsQ0FBM0IsRUFBQTtBQUFYOztBQXZJb0MiLCJzb3VyY2VzQ29udGVudCI6WyIjIGltcG9ydCB7IFRvdXJuYW1lbnQgfSBmcm9tICcuL3RvdXJuYW1lbnQuanMnIFxyXG5pbXBvcnQgeyBUYWJsZXMgfSBmcm9tICcuL3BhZ2VfdGFibGVzLmpzJyBcclxuaW1wb3J0IHsgTmFtZXMgfSBmcm9tICcuL3BhZ2VfbmFtZXMuanMnIFxyXG5pbXBvcnQgeyBTdGFuZGluZ3MgfSBmcm9tICcuL3BhZ2Vfc3RhbmRpbmdzLmpzJyBcclxuaW1wb3J0IHsgQWN0aXZlIH0gZnJvbSAnLi9wYWdlX2FjdGl2ZS5qcycgXHJcblxyXG5leHBvcnQgZyA9IHt9XHJcblxyXG4jIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjXHJcblxyXG5nLkVYUE9ORU5UID0gMS4wMSAjIDEgb3IgMS4wMSAob3IgMilcclxuZy5DT0xPUlMgPSAyICMgMiBlaiB0aWxsw6V0ZXQsIGTDpSBrYW4gd3d3IGVsbGVyIGJiYiB1cHBzdMOlLlxyXG5cclxuIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjI1xyXG5cclxuZXhwb3J0IHByaW50ID0gY29uc29sZS5sb2dcclxuZXhwb3J0IHJhbmdlID0gXy5yYW5nZVxyXG5leHBvcnQgc2NhbGV4ID0gKHgpIC0+IHggKiBnLlpPT01bZy5zdGF0ZV0gLyAyMFxyXG5leHBvcnQgc2NhbGV5ID0gKHkpIC0+IHkgKiBnLlpPT01bZy5zdGF0ZV1cclxuXHJcbmcuc2VlZCA9IDBcclxuZXhwb3J0IHJhbmRvbSA9IC0+ICgoKE1hdGguc2luKGcuc2VlZCsrKS8yKzAuNSkqMTAwMDApJTEwMCkvMTAwXHJcblxyXG5leHBvcnQgd3JhcCA9IChzKSAtPiBcIigje3N9KVwiXHJcblxyXG5nLkJZRSA9IC0xXHJcbmcuUEFVU0UgPSAtMlxyXG5cclxuZXhwb3J0IFNFUEFSQVRPUiA9ICchJ1xyXG5cclxuZy5UQUJMRVMgICAgPSAwXHJcbmcuTkFNRVMgICAgID0gMVxyXG5nLlNUQU5ESU5HUyA9IDJcclxuZy5BQ1RJVkUgICAgPSAzXHJcblxyXG5nLnBhZ2VzID0gW11cclxuXHJcbmcubWVzc2FnZSA9IFwiXCJcclxuXHJcbmcuRiA9IChkaWZmKSAtPiAxIC8gKDEgKyBwb3cgMTAsIC1kaWZmLzQwMClcclxuXHJcbmcuc2hvd1R5cGUgPSAoYSkgLT4gaWYgdHlwZW9mIGEgPT0gJ3N0cmluZycgdGhlbiBcIicje2F9J1wiIGVsc2UgYVxyXG5leHBvcnQgYXNzZXJ0ID0gKGEsYikgLT4gaWYgbm90IF8uaXNFcXVhbCBhLGIgdGhlbiBwcmludCBcIkFzc2VydCBmYWlsdXJlOiAje0pTT04uc3RyaW5naWZ5IGF9ICE9ICN7SlNPTi5zdHJpbmdpZnkgYn1cIlxyXG5cclxuZy5vayA9IChhLGIpIC0+IFxyXG5cdCMgaWYgZy50b3VybmFtZW50LnJvdW5kIDwgN1xyXG5cdGEuaWQgIT0gYi5pZCBhbmQgYS5pZCBub3QgaW4gYi5vcHAgYW5kIGFicyhhLmJhbGFucygpICsgYi5iYWxhbnMoKSkgPD0gMlxyXG5cdCMgZWxzZVxyXG5cdCMgXHRhLmlkICE9IGIuaWQgYW5kIGEuaWQgbm90IGluIGIub3BwIGFuZCBhYnMoYS5iYWxhbnMoKSArIGIuYmFsYW5zKCkpIDw9IDIgIzFcclxuXHJcbiMgZy5vayA9IChhLGIpIC0+IFxyXG4jIFx0bWFuZCA9IGEubWFuZGF0b3J5KCkgKyBiLm1hbmRhdG9yeSgpXHJcbiMgXHRhLmlkICE9IGIuaWQgYW5kIGEuaWQgbm90IGluIGIub3BwIGFuZCBtYW5kICE9IFwiYmJcIiBhbmQgbWFuZCAhPSBcInd3XCJcclxuXHJcbmcub3RoZXIgPSAoY29sKSAtPiBpZiBjb2wgPT0gJ2InIHRoZW4gJ3cnIGVsc2UgJ2InXHJcblxyXG5nLm15Um91bmQgPSAoeCxkZWNzKSAtPiB4LnRvRml4ZWQgZGVjc1xyXG5hc3NlcnQgXCIyLjBcIiwgZy5teVJvdW5kIDEuOTksMVxyXG5hc3NlcnQgXCIwLjZcIiwgZy5teVJvdW5kIDAuNjEsMVxyXG5cclxuZy5pbnRzMnN0cmluZ3MgPSAoaW50cykgLT4gXCIje2ludHN9XCJcclxuYXNzZXJ0IFwiMSwyLDNcIiwgZy5pbnRzMnN0cmluZ3MgWzEsMiwzXVxyXG5hc3NlcnQgXCIxXCIsIGcuaW50czJzdHJpbmdzIFsxXVxyXG5hc3NlcnQgXCJcIiwgZy5pbnRzMnN0cmluZ3MgW11cclxuXHJcbmcucmVzMnN0cmluZyA9IChpbnRzKSAtPiAoaS50b1N0cmluZygpIGZvciBpIGluIGludHMpLmpvaW4gJydcclxuYXNzZXJ0IFwiMTIzXCIsIGcucmVzMnN0cmluZyBbMSwyLDNdXHJcbmFzc2VydCBcIjFcIiwgZy5yZXMyc3RyaW5nIFsxXVxyXG5hc3NlcnQgXCJcIiwgZy5yZXMyc3RyaW5nIFtdXHJcblxyXG5nLnpvb21JbiAgPSAobikgLT4gZy5aT09NW2cuc3RhdGVdKytcclxuZy56b29tT3V0ID0gKG4pIC0+IGcuWk9PTVtnLnN0YXRlXS0tXHJcbmcuc2V0U3RhdGUgPSAobmV3U3RhdGUpIC0+IGlmIGcudG91cm5hbWVudC5yb3VuZCA+IDAgdGhlbiBnLnN0YXRlID0gbmV3U3RhdGVcclxuXHJcbmcuaW52ZXJ0ID0gKGFycikgLT5cclxuXHRyZXMgPSBbXVxyXG5cdGZvciBpIGluIHJhbmdlIGFyci5sZW5ndGhcclxuXHRcdHJlc1thcnJbaV1dID0gaVxyXG5cdHJlc1xyXG5hc3NlcnQgWzAsMSwyLDNdLCBnLmludmVydCBbMCwxLDIsM11cclxuYXNzZXJ0IFszLDIsMCwxXSwgZy5pbnZlcnQgWzIsMywxLDBdXHJcbmFzc2VydCBbMiwzLDEsMF0sIGcuaW52ZXJ0IGcuaW52ZXJ0IFsyLDMsMSwwXVxyXG5cclxueHh4ID0gW1syLDFdLFsxMiwyXSxbMTIsMV0sWzMsNF1dXHJcbnh4eC5zb3J0IChhLGIpIC0+IFxyXG5cdGRpZmYgPSBhWzBdIC0gYlswXSBcclxuXHRpZiBkaWZmID09IDAgdGhlbiBhWzFdIC0gYlsxXSBlbHNlIGRpZmZcclxuYXNzZXJ0IFtbMiwxXSwgWzMsNF0sIFsxMiwxXSwgWzEyLDJdXSwgeHh4XHRcclxuYXNzZXJ0IHRydWUsIFsyXSA+IFsxMl1cclxuYXNzZXJ0IHRydWUsIFwiMlwiID4gXCIxMlwiXHJcbmFzc2VydCBmYWxzZSwgMiA+IDEyXHJcblxyXG4jIHh4eCA9IFtbMiwxXSxbMTIsMl0sWzEyLDFdLFszLDRdXVxyXG4jIGFzc2VydCBbWzIsMV0sWzEyLDFdLFsxMiwyXSxbMyw0XV0sIF8uc29ydEJ5KHh4eCwgKHgpIC0+IFt4WzBdLHhbMV1dKVxyXG4jIGFzc2VydCBbWzMsNF0sWzIsMV0sWzEyLDFdLFsxMiwyXV0sIF8uc29ydEJ5KHh4eCwgKHgpIC0+IC14WzBdKVxyXG4jIGFzc2VydCBbWzIsMV0sWzEyLDFdLFszLDRdLFsxMiwyXV0sIF8uc29ydEJ5KHh4eCwgKHgpIC0+IHhbMV0pXHJcbiMgYXNzZXJ0IFtbMyw0XSxbMTIsMV0sWzIsMV0sWzEyLDJdXSwgXy5zb3J0QnkoeHh4LCAoeCkgLT4gLXhbMV0pXHJcblxyXG5nLmNhbGNNaXNzaW5nID0gLT5cclxuXHRtaXNzaW5nID0gMFxyXG5cdGZvciBwIGluIGcudG91cm5hbWVudC5wbGF5ZXJzQnlJRFxyXG5cdFx0aWYgbm90IHAuYWN0aXZlIHRoZW4gY29udGludWVcclxuXHRcdGlmIGcuQllFID09IF8ubGFzdCBwLm9wcCB0aGVuIGNvbnRpbnVlXHJcblx0XHRpZiBwLnJlcy5sZW5ndGggPCBwLmNvbC5sZW5ndGggdGhlbiBtaXNzaW5nKytcclxuXHQjIGcubWVzc2FnZSA9IFwiI3ttaXNzaW5nLy8yfSByZXN1bHRzIG1pc3NpbmdcIlxyXG5cdG1pc3NpbmcvLzJcclxuXHJcbmcuc3VtID0gKHMpIC0+XHJcblx0cmVzID0gMFxyXG5cdGZvciBpdGVtIGluIHNcclxuXHRcdHJlcyArPSBwYXJzZUZsb2F0IGl0ZW1cclxuXHRyZXNcclxuYXNzZXJ0IDYsIGcuc3VtICcwMTIwMTInXHJcblxyXG5nLnN1bU51bWJlcnMgPSAoYXJyKSAtPlxyXG5cdCMgcHJpbnQgJ3N1bU51bWJlcnMnLGFyclxyXG5cdHJlcyA9IDBcclxuXHRmb3IgaXRlbSBpbiBhcnJcclxuXHRcdHJlcyArPSBpdGVtXHJcblx0cmVzXHJcbmFzc2VydCAxNSwgZy5zdW1OdW1iZXJzIFsxLDIsMyw0LDVdXHJcblxyXG5nLnR4dFQgPSAodmFsdWUsIHcsIGFsaWduPSBDRU5URVIpIC0+IFxyXG5cdGlmIHZhbHVlLmxlbmd0aCA+IHcgdGhlbiB2YWx1ZSA9IHZhbHVlLnN1YnN0cmluZyAwLHdcclxuXHRpZiB2YWx1ZS5sZW5ndGggPCB3IGFuZCBhbGlnbj09IFJJR0hUIHRoZW4gdmFsdWUgPSB2YWx1ZS5wYWRTdGFydCB3XHJcblx0aWYgYWxpZ249PSBMRUZUIHRoZW4gcmVzID0gdmFsdWUgKyBfLnJlcGVhdCAnICcsdy12YWx1ZS5sZW5ndGhcclxuXHRpZiBhbGlnbj09IFJJR0hUIHRoZW4gcmVzID0gXy5yZXBlYXQoJyAnLHctdmFsdWUubGVuZ3RoKSArIHZhbHVlXHJcblx0aWYgYWxpZ249PSBDRU5URVIgXHJcblx0XHRkaWZmID0gdy12YWx1ZS5sZW5ndGhcclxuXHRcdGx0ID0gXy5yZXBlYXQgJyAnLCgxK2RpZmYpLy8yXHJcblx0XHRydCA9IF8ucmVwZWF0ICcgJyxkaWZmLy8yXHJcblx0XHRyZXMgPSBsdCArIHZhbHVlICsgcnRcclxuXHRyZXNcclxuXHJcbmcucHJCdGggPSAoc2NvcmUpIC0+IFwiI3snMMK9MSdbc2NvcmVdfS0jeycxwr0wJ1tzY29yZV19XCJcclxuZy5wckJvdGggPSAoc2NvcmUpIC0+IFwiICN7JzDCvTEnW3Njb3JlXX0gLSAjeycxwr0wJ1tzY29yZV19IFwiXHJcblxyXG4jIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyNcclxuXHJcbiJdfQ==
//# sourceURL=c:\github\FairPair\coffee\globals.coffee
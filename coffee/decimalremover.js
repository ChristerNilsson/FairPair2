// Generated by CoffeeScript 2.7.0
var rd;

export var DecimalRemover = class DecimalRemover {
  constructor(numbers) {
    var decimals, i, j, k, len, len1, len2, nr, number, ref, ref1, temp;
    temp = {}; // används för att bli av med dubletter
    for (i = 0, len = numbers.length; i < len; i++) {
      number = numbers[i];
      temp[number] = number;
    }
    numbers = _.values(temp);
    numbers = (function() {
      var j, len1, results;
      results = [];
      for (j = 0, len1 = numbers.length; j < len1; j++) {
        nr = numbers[j];
        results.push([nr, 0]);
      }
      return results;
    })();
    // anropa en extra gång för att förbättra resultatet. (decimaler läggs till vid behov)
    this.data = this.update(this.update(numbers));
    // Sök upp största antal decimaler
    this.n = _.maxBy(this.data, function(item) {
      return item[1];
    });
    print(this.n);
    this.n = this.n[1];
    this.hash = {};
    ref = this.data;
    for (j = 0, len1 = ref.length; j < len1; j++) {
      [nr, decimals] = ref[j];
      this.hash[nr] = decimals;
    }
    print('hash', this.hash);
    print('DecimalRemover', this.data);
    ref1 = this.data;
    for (k = 0, len2 = ref1.length; k < len2; k++) {
      [nr, decimals] = ref1[k];
      print(nr, this.format(nr));
    }
  }

  update(pairs, levels = 0) {
    var decimals, hash, i, key, len, nr, result;
    result = [];
    if (pairs.length === 1) {
      pairs[0][1] -= 1;
      return pairs;
    }
    hash = {};
    for (i = 0, len = pairs.length; i < len; i++) {
      [nr, decimals] = pairs[i];
      key = nr.toFixed(decimals);
      if (!(key in hash)) {
        hash[key] = [];
      }
      hash[key].push([nr, decimals + 1]);
    }
    for (key in hash) {
      result = result.concat(this.update(hash[key], levels + 1));
    }
    return result;
  }

  // uppdatera antalet decimaler så att varje tal blir unikt.
  // Börja med noll decimaler och lägg till fler vid behov.
  format(number) { // lista med flyttal
    var decimals, p, s;
    if (!(number in this.hash)) {
      return 'saknas';
    }
    decimals = Math.abs(this.hash[number]);
    // print 'format',number,decimals
    s = number.toFixed(decimals);
    // strings = (nr.toFixed decs for [nr,decs] in data)
    // Se till att decimalpunkterna kommer ovanför varandra
    // Lägg till blanktecken på höger sida.
    p = _.lastIndexOf(s, '.');
    if (p >= 0) {
      p = s.length - 1 - p;
    }
    return s + _.repeat(' ', this.n - p);
  }

};

rd = new DecimalRemover([1.23001, -1.19, 1.23578, 1.2397, 0, -10.3]);

assert("1.240", rd.format(1.2397));

assert("1.236", rd.format(1.23578));

assert("1.23 ", rd.format(1.23001));

assert("0    ", rd.format(0));

assert("-1    ", rd.format(-1.19));

assert("-10    ", rd.format(-10.3));

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiZGVjaW1hbHJlbW92ZXIuanMiLCJzb3VyY2VSb290IjoiLi5cXCIsInNvdXJjZXMiOlsiY29mZmVlXFxkZWNpbWFscmVtb3Zlci5jb2ZmZWUiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IjtBQUFBLElBQUE7O0FBQUEsT0FBQSxJQUFhLGlCQUFOLE1BQUEsZUFBQTtFQUNOLFdBQWMsQ0FBQyxPQUFELENBQUE7QUFDZixRQUFBLFFBQUEsRUFBQSxDQUFBLEVBQUEsQ0FBQSxFQUFBLENBQUEsRUFBQSxHQUFBLEVBQUEsSUFBQSxFQUFBLElBQUEsRUFBQSxFQUFBLEVBQUEsTUFBQSxFQUFBLEdBQUEsRUFBQSxJQUFBLEVBQUE7SUFBRSxJQUFBLEdBQU8sQ0FBQSxFQUFUO0lBQ0UsS0FBQSx5Q0FBQTs7TUFDQyxJQUFJLENBQUMsTUFBRCxDQUFKLEdBQWU7SUFEaEI7SUFFQSxPQUFBLEdBQVUsQ0FBQyxDQUFDLE1BQUYsQ0FBUyxJQUFUO0lBQ1YsT0FBQTs7QUFBVztNQUFBLEtBQUEsMkNBQUE7O3FCQUFBLENBQUMsRUFBRCxFQUFJLENBQUo7TUFBQSxDQUFBOztTQUpiOztJQU9FLElBQUMsQ0FBQSxJQUFELEdBQVEsSUFBQyxDQUFBLE1BQUQsQ0FBUSxJQUFDLENBQUEsTUFBRCxDQUFRLE9BQVIsQ0FBUixFQVBWOztJQVVFLElBQUMsQ0FBQSxDQUFELEdBQUssQ0FBQyxDQUFDLEtBQUYsQ0FBUSxJQUFDLENBQUEsSUFBVCxFQUFlLFFBQUEsQ0FBQyxJQUFELENBQUE7YUFBVSxJQUFJLENBQUMsQ0FBRDtJQUFkLENBQWY7SUFDTCxLQUFBLENBQU0sSUFBQyxDQUFBLENBQVA7SUFDQSxJQUFDLENBQUEsQ0FBRCxHQUFLLElBQUMsQ0FBQSxDQUFDLENBQUMsQ0FBRDtJQUVQLElBQUMsQ0FBQSxJQUFELEdBQVEsQ0FBQTtBQUNSO0lBQUEsS0FBQSx1Q0FBQTtNQUFJLENBQUMsRUFBRCxFQUFJLFFBQUo7TUFDSCxJQUFDLENBQUEsSUFBSSxDQUFDLEVBQUQsQ0FBTCxHQUFZ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ciA6IChudW1iZXJzKSAtPlxyXG5cdFx0dGVtcCA9IHt9ICMgYW52w6RuZHMgZsO2ciBhdHQgYmxpIGF2IG1lZCBkdWJsZXR0ZXJcclxuXHRcdGZvciBudW1iZXIgaW4gbnVtYmVyc1xyXG5cdFx0XHR0ZW1wW251bWJlcl0gPSBudW1iZXJcclxuXHRcdG51bWJlcnMgPSBfLnZhbHVlcyB0ZW1wXHJcblx0XHRudW1iZXJzID0gKFtuciwwXSBmb3IgbnIgaW4gbnVtYmVycylcclxuXHJcblx0XHQjIGFucm9wYSBlbiBleHRyYSBnw6VuZyBmw7ZyIGF0dCBmw7ZyYsOkdHRyYSByZXN1bHRhdGV0LiAoZGVjaW1hbGVyIGzDpGdncyB0aWxsIHZpZCBiZWhvdilcclxuXHRcdEBkYXRhID0gQHVwZGF0ZSBAdXBkYXRlIG51bWJlcnNcclxuXHJcblx0XHQjIFPDtmsgdXBwIHN0w7Zyc3RhIGFudGFsIGRlY2ltYWxlclxyXG5cdFx0QG4gPSBfLm1heEJ5IEBkYXRhLCAoaXRlbSkgLT4gaXRlbVsxXVxyXG5cdFx0cHJpbnQgQG5cclxuXHRcdEBuID0gQG5bMV1cclxuXHJcblx0XHRAaGFzaCA9IHt9XHJcblx0XHRmb3IgW25yLGRlY2ltYWxzXSBpbiBAZGF0YVxyXG5cdFx0XHRAaGFzaFtucl0gPSBkZWNpbWFsc1xyXG5cclxuXHRcdHByaW50ICdoYXNoJyxAaGFzaFxyXG5cclxuXHRcdHByaW50ICdEZWNpbWFsUmVtb3ZlcicsQGRhdGFcclxuXHRcdGZvciBbbnIsZGVjaW1hbHNdIGluIEBkYXRhXHJcblx0XHRcdHByaW50IG5yLEBmb3JtYXQgbnJcclxuXHJcblx0dXBkYXRlIDogKHBhaXJzLCBsZXZlbHM9MCkgLT5cclxuXHRcdHJlc3VsdCA9IFtdXHJcblx0XHRpZiBwYWlycy5sZW5ndGggPT0gMVxyXG5cdFx0XHRwYWlyc1swXVsxXSAtPSAxXHJcblx0XHRcdHJldHVybiBwYWlyc1xyXG5cdFx0aGFzaCA9IHt9XHJcblx0XHRmb3IgW25yLGRlY2ltYWxzXSBpbiBwYWlyc1xyXG5cdFx0XHRrZXkgPSBuci50b0ZpeGVkIGRlY2ltYWxzXHJcblx0XHRcdGlmIGtleSBub3Qgb2YgaGFzaCB0aGVuIGhhc2hba2V5XSA9IFtdXHJcblx0XHRcdGhhc2hba2V5XS5wdXNoIFtucixkZWNpbWFscysxXVxyXG5cdFx0Zm9yIGtleSBvZiBoYXNoXHJcblx0XHRcdHJlc3VsdCA9IHJlc3VsdC5jb25jYXQgQHVwZGF0ZSBoYXNoW2tleV0sIGxldmVscysxXHJcblx0XHRyZXR1cm4gcmVzdWx0XHJcblxyXG5cdCMgdXBwZGF0ZXJhIGFudGFsZXQgZGVjaW1hbGVyIHPDpSBhdHQgdmFyamUgdGFsIGJsaXIgdW5pa3QuXHJcblx0IyBCw7ZyamEgbWVkIG5vbGwgZGVjaW1hbGVyIG9jaCBsw6RnZyB0aWxsIGZsZXIgdmlkIGJlaG92LlxyXG5cdGZvcm1hdCA6IChudW1iZXIpIC0+ICMgbGlzdGEgbWVkIGZseXR0YWxcclxuXHRcdGlmIG51bWJlciBub3Qgb2YgQGhhc2ggdGhlbiByZXR1cm4gJ3Nha25hcydcclxuXHRcdGRlY2ltYWxzID0gTWF0aC5hYnMgQGhhc2hbbnVtYmVyXVxyXG5cdFx0IyBwcmludCAnZm9ybWF0JyxudW1iZXIsZGVjaW1hbHNcclxuXHRcdHMgPSBudW1iZXIudG9GaXhlZCBkZWNpbWFsc1xyXG5cdFx0IyBzdHJpbmdzID0gKG5yLnRvRml4ZWQgZGVjcyBmb3IgW25yLGRlY3NdIGluIGRhdGEpXHJcblx0XHQjIFNlIHRpbGwgYXR0IGRlY2ltYWxwdW5rdGVybmEga29tbWVyIG92YW5mw7ZyIHZhcmFuZHJhXHJcblx0XHQjIEzDpGdnIHRpbGwgYmxhbmt0ZWNrZW4gcMOlIGjDtmdlciBzaWRhLlxyXG5cdFx0cCA9IF8ubGFzdEluZGV4T2YgcywgJy4nXHJcblx0XHRpZiBwID49IDAgdGhlbiBwID0gcy5sZW5ndGggLSAxIC0gcFxyXG5cdFx0cyArIF8ucmVwZWF0ICcgJywgQG4gLSBwXHJcblxyXG5yZCA9IG5ldyBEZWNpbWFsUmVtb3ZlciBbMS4yMzAwMSwgLTEuMTksIDEuMjM1NzgsIDEuMjM5NywgMCwgLTEwLjNdXHJcbmFzc2VydCAgIFwiMS4yNDBcIiwgcmQuZm9ybWF0IDEuMjM5N1xyXG5hc3NlcnQgICBcIjEuMjM2XCIsIHJkLmZvcm1hdCAxLjIzNTc4XHJcbmFzc2VydCAgIFwiMS4yMyBcIiwgcmQuZm9ybWF0IDEuMjMwMDFcclxuYXNzZXJ0ICAgXCIwICAgIFwiLCByZC5mb3JtYXQgMFxyXG5hc3NlcnQgIFwiLTEgICAgXCIsIHJkLmZvcm1hdCAtMS4xOVxyXG5hc3NlcnQgXCItMTAgICAgXCIsIHJkLmZvcm1hdCAtMTAuM1xyXG4iXX0=
//# sourceURL=c:\github\ELO-Pairings\coffee\decimalremover.coffee
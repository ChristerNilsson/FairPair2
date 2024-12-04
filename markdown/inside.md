# Inside information

If you are interested in the inner workings, this is for you.

* The language used is coffeescript, transpiled to javascript
* The algorithm [blossom](../js/blossom.js) is used for the pairings.
    * Special thanks to
        * Jack Edmonds, who designed the [algorithm](https://en.wikipedia.org/wiki/Blossom_algorithm) in 1965
        * Zvi Galil, who implemented it in Python 1986
        * Matt Krick, who translated it to [Javascript](https://github.com/mattkrick/EdmondsBlossom) in 2015
    * To speed up Blossom, I'm using an iterative approach, with smallest costs first
        * Reason: Blossom is quadratic.
        * 1000 players pairs in half a second in round 10.
            * That is about twenty times faster than using no iteration.
* Libraries:
    * p5
    * lodash

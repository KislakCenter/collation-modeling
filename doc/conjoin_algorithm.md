# Conjoin algorithm

```

1)  ----- 1*    2)  ----- 1     3)  ----- 1    4)   ------ 1
    ----- 2        |  --- 2*       |  --- 2        |  ---- 2
   |  --- 3        |  --- 3        | |  - 3*       | |  -- 3
   | |  - 4        | |  - 4        | |  - 4        | | | - 4*
   | | |           | | |           | | |           | | |
   | |  - 5        | |  - 5        | |  - 5        | |  -- 5
   |  --- 6        |  --- 6        |  --- 6        |  ---- 6
    ----- 7         ----- 7         ----- 7         ------ 7


5)  ----- 1    6)   ----- 1     7)  ----- 1
   |  --- 2        |  --- 2        |  --- 2
   | |  - 3        | |  - 3        | |  - 3
   | | |           | | |           | | |
   | |  - 4        | |  - 4        | |  - 4
   | |  - 5*       |  --- 5        |  --- 5
   |  --- 6        |  --- 6*       |  --- 6*
    ----- 7         ----- 7         ----- 7

 ```

Note that below we have the concept of an `unjoined` leaf. This has to do with
diagramming. The diagram model is balanced; that is, even when we have
singles, the digram displays an empty slot (perhaps at a blank or dotted
line), where the conjoin would be if it existed, like so:

```
 --------- 1
|  ------- 2 (single)
| |  ----- 3
| | |  --- 4
| | | |
| | |  --- 5
| |  ----- 6
|  - - - - x (false leaf)
 --------- 7
```

When we process a single leaf, we create this placeholder, by inserting a joined
''false leaf'' before the conjoin of the previous leaf or after the conjoin of the next leaf, which is determined by whether the current leaf is before or after the center. Each time we make such a
connection, we restart the search.

Since we create `false` leaves to fill out the leaf structure for

- Find conjoins

- process_singles()
    - From the front, find singles
        - if leaf.unjoined?, process_single(leaf)
        - process_single(leaf)
            - if leaf.first?
                - insert false_leaf after last
                - join leaf to false_leaf
                - return process_singles()
            - if leaf.last?
                - insert false_leaf before first
                - join leaf to false_leaf
                - return process_singles()
            - if leaf.middle? [i.e., size.odd? and leaf.posn == (size+1)/2]
                - insert false_leaf after leaf
                - join leaf and false_leaf
                - return process_singles()
            - if leaf.posn <= (size+1)/2:
                - insert false_leaf before prev.conjoin
                - join leaf and false_leaf
                - return process_singles()
            - if leaf.posn > (size+1)/2:
                if next.unjoined?
                    - process_single(next)
                else
                    - insert false_leaf after next.conjoin
                    - join leaf and false_leaf
                    - return process_singles()


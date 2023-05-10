# ore-excavator-tunnel-mining-turtle
Ore Excavator Tunnel Mining Turtle is a program for computercraft turtles. \
I didn't like the idea to excavate large areas to find resources. The main purpose was to excavate a 3x3 tunnel while also **mining out all the ore that is visible from the wall and everything else valuable that was connected to it.**

### Current features are:
- Mines a 3x3 tunnel for the given length
- Mines ore in the walls end every ore connected to it
- Falling block proof
- Returns to the starting point
- Unloads inventory when returned. Chest must be behind or above the starting point.
- Throws out trash every second turn
- Fills in a 3 wide walkway when there is no block on the tunnel's floor and side on the bottom level **(Uses blocks from slot 1)**
- Auto return when inventory is full, unload and continue mining

### Reserved slots:
- Slot 1 for building material
- Slot 2 for empty buckets

### Planned features:
- Place torches
- Refuel from lava before moving into it
- Make a wall to prevents liquids flowing in
- Refuel from lava before placing a block on it
- Optionally collect lava with buckets **(slot 2 reserved for buckets)**
- Branching


This was a proof of concept job. Heavy refactoring and optimization is needed. The turtle currently moves around a lot when it looks for ore. Especially on the way back to continue tunneling.


### Known issues
- Unloading the inventory is stuck when there is an empty slot
- When waiting for an inventory to drop items, only checking the front or above block. It needs to be changed for alternate checking while waiting.
- When the turtle is coming back, it destroys chests if it was placed in it's path

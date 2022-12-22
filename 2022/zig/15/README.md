The first day where brute-force approach fails (pt 2). `4000000` is a big number and constructing `4000000 x 4000000` matrix, is both memory and computation expensive.

I created methods for constructing ranges of `x` coordinates that are covered in `y`th row based on input sensors (that allow their assigned beacon to still be the first one to reach). This worked fine for pt 1.

What I ended up doing for pt 2 is creating `RangeSet` `struct` that would hold a minimal list of all the `Range`s that merge all the inserted `Range` objects. When a row is found where such `Range` union is not starting from `0` **or** not ending at `4000001` **or** there are 2 ranges with 1 `x` missing between them the missing beacon is found (assuming only one exists).
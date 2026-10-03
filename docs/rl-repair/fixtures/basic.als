sig S { r: set S }
pred candidate { all x: S | some x.r }
pred oracle { all y: S | no y.r }
run {} for 3 but 4 Int

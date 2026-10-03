sig Item { p, q: set Item }
pred candidate { no (Item.p & Item.q) }
pred oracle { some (Item.p & Item.q) }
run {} for 3

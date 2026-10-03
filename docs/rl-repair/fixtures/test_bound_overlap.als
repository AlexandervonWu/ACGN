sig Node { left, right: set Node }
pred candidate { all x: Node | no (x.left & x.right) }
pred oracle { all x: Node | some (x.left & x.right) }
run {} for 3

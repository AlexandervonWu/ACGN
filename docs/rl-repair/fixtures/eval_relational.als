sig Node { left, right: set Node }
pred candidate { some (Node.left + Node.right) }
pred oracle { some (Node.left & Node.right) }
run {} for 3

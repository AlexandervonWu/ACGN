sig Node { left, right, allowed: set Node }
pred candidate { some ((Node.left + Node.right) & Node.allowed) }
pred oracle { some ((Node.left & Node.right) & Node.allowed) }
run {} for 3

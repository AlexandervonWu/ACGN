sig Person { friends: set Person }
pred candidate { some p: Person | no p.friends }
pred oracle { some p: Person | some p.friends }
run {} for 3 but 4 Int

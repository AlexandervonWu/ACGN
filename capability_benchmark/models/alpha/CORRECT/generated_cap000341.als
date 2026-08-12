sig User {
	follows : set User,
	sees : set Photo,
	posts : set Photo,
	suggested : set User
}

sig Influencer extends User {}

sig Photo {
	date : one Day
}
sig Ad extends Photo {}

sig Day {}

pred inv7 {
all u, s: User | s in u.suggested iff s not in u.follows and s in u.follows.follows and s != u
}

pred inv7c {
	all u : User | u.suggested = u.follows.follows - u.follows - u
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000341 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv7 and ((some capBenchS or no CapBenchA) or some capBenchS))) }
pred cap000341c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv7 and ((some capBenchS or no CapBenchA) or some capBenchS))) }
assert CapBenchEquivalent_cap000341 { cap000341 iff cap000341c }
check CapBenchEquivalent_cap000341 for 4

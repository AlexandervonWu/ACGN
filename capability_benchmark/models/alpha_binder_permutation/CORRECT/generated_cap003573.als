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

pred inv2 {
all u : User | u not in u.follows
}

pred inv2c {
	all p : User | p not in p.follows
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003573 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((some CapBenchB or some CapBenchB) or some CapBenchB))) }
pred cap003573c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv2 and ((some CapBenchB or some CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap003573 { cap003573 iff cap003573c }
check CapBenchEquivalent_cap003573 for 4

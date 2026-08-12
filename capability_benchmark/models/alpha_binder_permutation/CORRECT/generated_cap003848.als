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
all u : User | u not in follows.u
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

pred cap003848 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((some capBenchR and no CapBenchB) or some capBenchS))) }
pred cap003848c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv2 and ((some capBenchR and no CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap003848 { cap003848 iff cap003848c }
check CapBenchEquivalent_cap003848 for 4

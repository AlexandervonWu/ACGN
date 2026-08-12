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

pred cap003854 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((no CapBenchA and some capBenchR) and some capBenchS))) }
pred cap003854c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv2 and ((no CapBenchA and some capBenchR) and some capBenchS))) }
assert CapBenchEquivalent_cap003854 { cap003854 iff cap003854c }
check CapBenchEquivalent_cap003854 for 4

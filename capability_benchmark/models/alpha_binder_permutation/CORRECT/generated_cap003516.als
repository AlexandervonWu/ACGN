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
all u:User | u not in u.follows
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

pred cap003516 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((some CapBenchA and no CapBenchA) or some CapBenchA))) }
pred cap003516c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv2 and ((some CapBenchA and no CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap003516 { cap003516 iff cap003516c }
check CapBenchEquivalent_cap003516 for 4

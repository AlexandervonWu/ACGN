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
all x : User | x not in follows.x
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

pred cap003793 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((some capBenchS or some capBenchR) or some capBenchR))) }
pred cap003793c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv2 and ((some capBenchS or some capBenchR) or some capBenchR))) }
assert CapBenchEquivalent_cap003793 { cap003793 iff cap003793c }
check CapBenchEquivalent_cap003793 for 4

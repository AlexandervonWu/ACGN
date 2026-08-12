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

pred cap005124 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)) and ((some CapBenchB or some capBenchS) or some capBenchR))) }
pred cap005124c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or some capBenchS) or some capBenchR)) or (not (inv2 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)))) }
assert CapBenchEquivalent_cap005124 { cap005124 iff cap005124c }
check CapBenchEquivalent_cap005124 for 4

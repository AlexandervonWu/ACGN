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

pred cap005127 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchB)) and ((some capBenchR and some capBenchS) or some capBenchR))) }
pred cap005127c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchR and some capBenchS) or some capBenchR)) or (not (inv2 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchB)))) }
assert CapBenchEquivalent_cap005127 { cap005127 iff cap005127c }
check CapBenchEquivalent_cap005127 for 4

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
all u:User|  u not in u.follows
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

pred cap005208 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((some CapBenchA and no CapBenchA) or no CapBenchB)) and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
pred cap005208c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) or (not (inv2 and ((some CapBenchA and no CapBenchA) or no CapBenchB)))) }
assert CapBenchEquivalent_cap005208 { cap005208 iff cap005208c }
check CapBenchEquivalent_cap005208 for 4

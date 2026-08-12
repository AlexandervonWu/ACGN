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

pred cap001828 { ((some x: CapBenchA | x->x in capBenchR) and (inv2 and ((some CapBenchA and some CapBenchB) or some capBenchS))) }
pred cap001828c { (some x: CapBenchA | (x->x in capBenchR and (inv2 and ((some CapBenchA and some CapBenchB) or some capBenchS)))) }
assert CapBenchEquivalent_cap001828 { cap001828 iff cap001828c }
check CapBenchEquivalent_cap001828 for 4

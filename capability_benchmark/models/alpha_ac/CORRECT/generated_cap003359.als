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

pred cap003359 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchS)) and ((some capBenchR and no CapBenchA) or some CapBenchA)) }
pred cap003359c { all renamed: CapBenchA | (((some capBenchR and no CapBenchA) or some CapBenchA) and renamed->renamed in capBenchR and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchS))) }
assert CapBenchEquivalent_cap003359 { cap003359 iff cap003359c }
check CapBenchEquivalent_cap003359 for 4

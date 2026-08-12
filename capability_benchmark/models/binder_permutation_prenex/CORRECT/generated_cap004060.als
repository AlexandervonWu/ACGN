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

pred cap004060 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv2 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA))) }
pred cap004060c { some a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap004060 { cap004060 iff cap004060c }
check CapBenchEquivalent_cap004060 for 4

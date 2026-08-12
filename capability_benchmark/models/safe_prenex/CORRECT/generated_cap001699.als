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
all x : User | x not in x.follows
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

pred cap001699 { ((all x: CapBenchA | x->x in capBenchR) or (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchB))) }
pred cap001699c { (all x: CapBenchA | (x->x in capBenchR or (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchB)))) }
assert CapBenchEquivalent_cap001699 { cap001699 iff cap001699c }
check CapBenchEquivalent_cap001699 for 4

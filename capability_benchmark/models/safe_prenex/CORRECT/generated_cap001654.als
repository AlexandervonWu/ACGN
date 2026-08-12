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

pred cap001654 { ((some x: CapBenchA | x->x in capBenchR) and (inv2 and ((no CapBenchA and no CapBenchB) and no CapBenchA))) }
pred cap001654c { (some x: CapBenchA | (x->x in capBenchR and (inv2 and ((no CapBenchA and no CapBenchB) and no CapBenchA)))) }
assert CapBenchEquivalent_cap001654 { cap001654 iff cap001654c }
check CapBenchEquivalent_cap001654 for 4

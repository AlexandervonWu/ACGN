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

pred cap001991 { ((all x: CapBenchA | x->x in capBenchR) or (inv2 and ((no CapBenchB or some capBenchS) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap001991c { (all x: CapBenchA | (x->x in capBenchR or (inv2 and ((no CapBenchB or some capBenchS) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap001991 { cap001991 iff cap001991c }
check CapBenchEquivalent_cap001991 for 4

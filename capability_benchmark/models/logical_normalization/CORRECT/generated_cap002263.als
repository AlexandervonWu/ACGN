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
all u:User | u not in follows.u
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

pred cap002263 { no x: CapBenchA | (x->x in capBenchR and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchR))) }
pred cap002263c { all x: CapBenchA | not (x->x in capBenchR and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap002263 { cap002263 iff cap002263c }
check CapBenchEquivalent_cap002263 for 4

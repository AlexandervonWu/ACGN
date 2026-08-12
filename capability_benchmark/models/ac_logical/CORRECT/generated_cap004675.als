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
all u: User | u -> u not in follows
all u: User | u not in u.follows
follows - iden = follows
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

pred cap004675 { not ((inv2 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchA)) and ((some capBenchR and no CapBenchB) or some capBenchS)) }
pred cap004675c { ((not ((some capBenchR and no CapBenchB) or some capBenchS)) or (not (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchA)))) }
assert CapBenchEquivalent_cap004675 { cap004675 iff cap004675c }
check CapBenchEquivalent_cap004675 for 4

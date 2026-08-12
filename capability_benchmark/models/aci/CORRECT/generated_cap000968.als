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

pred cap000968 { ((inv2 and ((some capBenchR and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchB or some CapBenchA) or no CapBenchA) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchR)) }
pred cap000968c { (((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchR) and (inv2 and ((some capBenchR and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchB or some CapBenchA) or no CapBenchA)) }
assert CapBenchEquivalent_cap000968 { cap000968 iff cap000968c }
check CapBenchEquivalent_cap000968 for 4

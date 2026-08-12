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
all u : User | u not in follows.u
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

pred cap000855 { ((inv2 and ((no CapBenchB or some capBenchR) and some capBenchS)) or ((some CapBenchA and no CapBenchA) or some CapBenchA) or ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and no CapBenchA)) }
pred cap000855c { (((some CapBenchA and no CapBenchA) or some CapBenchA) or ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and no CapBenchA) or (inv2 and ((no CapBenchB or some capBenchR) and some capBenchS))) }
assert CapBenchEquivalent_cap000855 { cap000855 iff cap000855c }
check CapBenchEquivalent_cap000855 for 4

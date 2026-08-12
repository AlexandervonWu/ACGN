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

pred cap000896 { ((inv2 and ((some capBenchR and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchB)) }
pred cap000896c { (((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchB) and (inv2 and ((some capBenchR and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) }
assert CapBenchEquivalent_cap000896 { cap000896 iff cap000896c }
check CapBenchEquivalent_cap000896 for 4

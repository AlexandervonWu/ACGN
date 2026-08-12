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

pred cap000981 { ((inv2 and ((some CapBenchB or some capBenchR) or CapBenchA in CapBenchA + CapBenchB)) or ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchA) or ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchR)) }
pred cap000981c { (((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchA) or ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchR) or (inv2 and ((some CapBenchB or some capBenchR) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap000981 { cap000981 iff cap000981c }
check CapBenchEquivalent_cap000981 for 4

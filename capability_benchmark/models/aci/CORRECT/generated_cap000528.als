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

pred cap000528 { (some (((CapBenchA + CapBenchB) & CapBenchA) & CapBenchA) and (inv2 and ((some capBenchR and no CapBenchB) or some CapBenchA))) }
pred cap000528c { (some ((CapBenchA + CapBenchB) & (CapBenchA & CapBenchA)) and (inv2 and ((some capBenchR and no CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap000528 { cap000528 iff cap000528c }
check CapBenchEquivalent_cap000528 for 4

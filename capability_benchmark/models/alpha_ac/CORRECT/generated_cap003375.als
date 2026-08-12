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

pred inv1 {
all p:Photo | one posts.p
}

pred inv1c {
	all p : Photo | one posts.p
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003375 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS)) and ((some capBenchR and some capBenchR) or some CapBenchA)) }
pred cap003375c { all renamed: CapBenchA | (((some capBenchR and some capBenchR) or some CapBenchA) and renamed->renamed in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS))) }
assert CapBenchEquivalent_cap003375 { cap003375 iff cap003375c }
check CapBenchEquivalent_cap003375 for 4

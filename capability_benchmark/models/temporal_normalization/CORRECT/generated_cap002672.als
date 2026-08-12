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
all u: User| u not in follows.u
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

pred cap002672 { not (((inv2 and ((some capBenchR and some capBenchS) or no CapBenchA))) until (((some CapBenchB or no CapBenchB) or some capBenchS))) }
pred cap002672c { ((not (inv2 and ((some capBenchR and some capBenchS) or no CapBenchA))) releases (not ((some CapBenchB or no CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap002672 { cap002672 iff cap002672c }
check CapBenchEquivalent_cap002672 for 4

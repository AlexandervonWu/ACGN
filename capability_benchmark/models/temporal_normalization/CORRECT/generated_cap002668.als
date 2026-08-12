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

pred cap002668 { not always ((inv2 and ((some CapBenchA and some capBenchS) or no CapBenchA))) }
pred cap002668c { eventually (not (inv2 and ((some CapBenchA and some capBenchS) or no CapBenchA))) }
assert CapBenchEquivalent_cap002668 { cap002668 iff cap002668c }
check CapBenchEquivalent_cap002668 for 4

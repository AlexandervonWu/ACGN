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

pred cap002163 { not ((inv2 and ((no CapBenchB or some capBenchR) and no CapBenchA)) and ((some CapBenchA and no CapBenchA) or some capBenchS)) }
pred cap002163c { ((not (inv2 and ((no CapBenchB or some capBenchR) and no CapBenchA))) or (not ((some CapBenchA and no CapBenchA) or some capBenchS))) }
assert CapBenchEquivalent_cap002163 { cap002163 iff cap002163c }
check CapBenchEquivalent_cap002163 for 4

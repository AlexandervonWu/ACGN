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
all x : User | x -> x not in follows
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

pred cap002325 { not ((inv2 and ((some capBenchS or some CapBenchA) or some capBenchS)) and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap002325c { ((not (inv2 and ((some capBenchS or some CapBenchA) or some capBenchS))) or (not ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002325 { cap002325 iff cap002325c }
check CapBenchEquivalent_cap002325 for 4

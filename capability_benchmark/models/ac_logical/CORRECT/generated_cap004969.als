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

pred cap004969 { not ((inv2 and ((some capBenchS or no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) and ((no CapBenchA and some CapBenchA) and no CapBenchA)) }
pred cap004969c { ((not ((no CapBenchA and some CapBenchA) and no CapBenchA)) or (not (inv2 and ((some capBenchS or no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004969 { cap004969 iff cap004969c }
check CapBenchEquivalent_cap004969 for 4

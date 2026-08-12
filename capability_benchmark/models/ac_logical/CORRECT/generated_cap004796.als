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

pred cap004796 { not ((inv2 and ((some CapBenchA and some capBenchS) or some capBenchR)) and ((some capBenchS or no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap004796c { ((not ((some capBenchS or no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv2 and ((some CapBenchA and some capBenchS) or some capBenchR)))) }
assert CapBenchEquivalent_cap004796 { cap004796 iff cap004796c }
check CapBenchEquivalent_cap004796 for 4

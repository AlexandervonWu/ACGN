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

pred cap004593 { not ((inv2 and ((some capBenchS or no CapBenchB) or some CapBenchB)) and ((no CapBenchA and some CapBenchB) and some capBenchR)) }
pred cap004593c { ((not ((no CapBenchA and some CapBenchB) and some capBenchR)) or (not (inv2 and ((some capBenchS or no CapBenchB) or some CapBenchB)))) }
assert CapBenchEquivalent_cap004593 { cap004593 iff cap004593c }
check CapBenchEquivalent_cap004593 for 4

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

pred cap004927 { not ((inv2 and ((no CapBenchB or some capBenchS) and capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchA and no CapBenchB) or some CapBenchB)) }
pred cap004927c { ((not ((some CapBenchA and no CapBenchB) or some CapBenchB)) or (not (inv2 and ((no CapBenchB or some capBenchS) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004927 { cap004927 iff cap004927c }
check CapBenchEquivalent_cap004927 for 4

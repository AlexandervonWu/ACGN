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
all u:User|  u not in u.follows
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

pred cap004926 { not ((inv2 and ((no CapBenchA and some capBenchS) and capBenchR in (CapBenchA -> CapBenchA))) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchB)) }
pred cap004926c { ((not ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchB)) or (not (inv2 and ((no CapBenchA and some capBenchS) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004926 { cap004926 iff cap004926c }
check CapBenchEquivalent_cap004926 for 4

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

pred cap004900 { not ((inv2 and ((some CapBenchA and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) }
pred cap004900c { ((not ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) or (not (inv2 and ((some CapBenchA and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004900 { cap004900 iff cap004900c }
check CapBenchEquivalent_cap004900 for 4

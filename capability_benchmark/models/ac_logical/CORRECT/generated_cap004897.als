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
all x : User | x not in x.follows
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

pred cap004897 { not ((inv2 and ((some capBenchS or some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchA)) }
pred cap004897c { ((not ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchA)) or (not (inv2 and ((some capBenchS or some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004897 { cap004897 iff cap004897c }
check CapBenchEquivalent_cap004897 for 4

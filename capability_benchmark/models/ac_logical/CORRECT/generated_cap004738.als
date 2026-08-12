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

pred cap004738 { not ((inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchB)) and ((no CapBenchB or no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004738c { ((not ((no CapBenchB or no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) or (not (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchB)))) }
assert CapBenchEquivalent_cap004738 { cap004738 iff cap004738c }
check CapBenchEquivalent_cap004738 for 4

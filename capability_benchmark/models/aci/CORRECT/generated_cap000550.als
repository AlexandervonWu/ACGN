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

pred cap000550 { (inv2 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)) }
pred cap000550c { ((inv2 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)) and (inv2 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA))) }
assert CapBenchEquivalent_cap000550 { cap000550 iff cap000550c }
check CapBenchEquivalent_cap000550 for 4

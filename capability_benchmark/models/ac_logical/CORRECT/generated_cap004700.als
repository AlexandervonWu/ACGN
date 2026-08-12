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

pred cap004700 { not ((inv2 and ((some CapBenchA and some CapBenchB) or no CapBenchB)) and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) }
pred cap004700c { ((not ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) or (not (inv2 and ((some CapBenchA and some CapBenchB) or no CapBenchB)))) }
assert CapBenchEquivalent_cap004700 { cap004700 iff cap004700c }
check CapBenchEquivalent_cap004700 for 4

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

pred cap004748 { not ((inv2 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)) and ((some capBenchS or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004748c { ((not ((some capBenchS or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv2 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)))) }
assert CapBenchEquivalent_cap004748 { cap004748 iff cap004748c }
check CapBenchEquivalent_cap004748 for 4

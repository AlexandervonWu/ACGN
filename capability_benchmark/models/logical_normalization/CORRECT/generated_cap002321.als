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

pred cap002321 { ((inv2 and ((some CapBenchB or some CapBenchA) or some capBenchS)) iff ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap002321c { (((not (inv2 and ((some CapBenchB or some CapBenchA) or some capBenchS))) or ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and CapBenchA in CapBenchA + CapBenchB)) and ((not ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and CapBenchA in CapBenchA + CapBenchB)) or (inv2 and ((some CapBenchB or some CapBenchA) or some capBenchS)))) }
assert CapBenchEquivalent_cap002321 { cap002321 iff cap002321c }
check CapBenchEquivalent_cap002321 for 4

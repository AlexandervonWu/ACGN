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
all u : User | u not in u.follows
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

pred cap005245 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)) and ((no CapBenchA and some capBenchR) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap005245c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and some capBenchR) and capBenchR in (CapBenchA -> CapBenchA))) or (not (inv2 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)))) }
assert CapBenchEquivalent_cap005245 { cap005245 iff cap005245c }
check CapBenchEquivalent_cap005245 for 4

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

pred cap003043 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((no CapBenchB or some capBenchS) and some CapBenchA)) and ((some CapBenchA and no CapBenchB) or no CapBenchB)) }
pred cap003043c { all renamed: CapBenchA | (((some CapBenchA and no CapBenchB) or no CapBenchB) and renamed->renamed in capBenchR and (inv2 and ((no CapBenchB or some capBenchS) and some CapBenchA))) }
assert CapBenchEquivalent_cap003043 { cap003043 iff cap003043c }
check CapBenchEquivalent_cap003043 for 4

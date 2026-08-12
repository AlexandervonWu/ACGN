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

pred cap003076 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some capBenchR and some CapBenchB) or some CapBenchB)) and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)) }
pred cap003076c { all renamed: CapBenchA | (((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB) and renamed->renamed in capBenchR and (inv2 and ((some capBenchR and some CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap003076 { cap003076 iff cap003076c }
check CapBenchEquivalent_cap003076 for 4

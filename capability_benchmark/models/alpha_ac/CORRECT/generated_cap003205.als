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
all u:User | u not in u.follows
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

pred cap003205 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some capBenchS or some CapBenchB) or no CapBenchB)) and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchS)) }
pred cap003205c { all renamed: CapBenchA | (((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchS) and renamed->renamed in capBenchR and (inv2 and ((some capBenchS or some CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap003205 { cap003205 iff cap003205c }
check CapBenchEquivalent_cap003205 for 4

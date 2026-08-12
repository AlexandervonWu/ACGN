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

pred cap003453 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some capBenchS or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB)) }
pred cap003453c { all renamed: CapBenchA | (((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB) and renamed->renamed in capBenchR and (inv2 and ((some capBenchS or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003453 { cap003453 iff cap003453c }
check CapBenchEquivalent_cap003453 for 4

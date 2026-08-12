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

pred cap003396 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some capBenchR and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) }
pred cap003396c { all renamed: CapBenchA | (((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA) and renamed->renamed in capBenchR and (inv2 and ((some capBenchR and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003396 { cap003396 iff cap003396c }
check CapBenchEquivalent_cap003396 for 4

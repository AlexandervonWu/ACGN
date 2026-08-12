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
all u : User | u not in follows.u
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

pred cap003400 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some CapBenchA and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) }
pred cap003400c { all renamed: CapBenchA | (((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA) and renamed->renamed in capBenchR and (inv2 and ((some CapBenchA and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003400 { cap003400 iff cap003400c }
check CapBenchEquivalent_cap003400 for 4

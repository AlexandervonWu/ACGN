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
all u:User | u not in follows.u
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

pred cap003452 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some capBenchR and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)) }
pred cap003452c { all renamed: CapBenchA | (((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB) and renamed->renamed in capBenchR and (inv2 and ((some capBenchR and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003452 { cap003452 iff cap003452c }
check CapBenchEquivalent_cap003452 for 4

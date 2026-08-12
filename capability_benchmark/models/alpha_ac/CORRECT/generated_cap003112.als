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

pred cap003112 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)) and ((some capBenchS or no CapBenchB) or some capBenchR)) }
pred cap003112c { all renamed: CapBenchA | (((some capBenchS or no CapBenchB) or some capBenchR) and renamed->renamed in capBenchR and (inv2 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB))) }
assert CapBenchEquivalent_cap003112 { cap003112 iff cap003112c }
check CapBenchEquivalent_cap003112 for 4

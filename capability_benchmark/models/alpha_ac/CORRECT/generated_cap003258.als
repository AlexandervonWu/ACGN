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
all u:User|  u not in u.follows
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

pred cap003258 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((no CapBenchA and some CapBenchA) and some capBenchR)) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003258c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv2 and ((no CapBenchA and some CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap003258 { cap003258 iff cap003258c }
check CapBenchEquivalent_cap003258 for 4

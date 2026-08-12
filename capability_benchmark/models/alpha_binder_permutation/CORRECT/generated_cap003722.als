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

pred cap003722 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchB))) }
pred cap003722c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap003722 { cap003722 iff cap003722c }
check CapBenchEquivalent_cap003722 for 4

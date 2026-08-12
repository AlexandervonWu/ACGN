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
all u: User| u not in follows.u
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

pred cap001470 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap001470c { all a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap001470 { cap001470 iff cap001470c }
check CapBenchEquivalent_cap001470 for 4

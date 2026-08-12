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

pred cap001156 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((some capBenchR and no CapBenchB) or no CapBenchA))) }
pred cap001156c { all a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((some capBenchR and no CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap001156 { cap001156 iff cap001156c }
check CapBenchEquivalent_cap001156 for 4

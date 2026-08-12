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

pred cap001076 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((some capBenchR and some CapBenchB) or some CapBenchB))) }
pred cap001076c { all a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((some capBenchR and some CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap001076 { cap001076 iff cap001076c }
check CapBenchEquivalent_cap001076 for 4

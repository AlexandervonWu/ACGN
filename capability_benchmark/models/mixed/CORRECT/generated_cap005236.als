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

pred cap005236 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((some capBenchR and some capBenchS) or no CapBenchB)) and ((some CapBenchB or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap005236c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv2 and ((some capBenchR and some capBenchS) or no CapBenchB)))) }
assert CapBenchEquivalent_cap005236 { cap005236 iff cap005236c }
check CapBenchEquivalent_cap005236 for 4

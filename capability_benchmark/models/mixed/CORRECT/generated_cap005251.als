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

pred cap005251 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchB)) and ((some CapBenchA and some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap005251c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv2 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchB)))) }
assert CapBenchEquivalent_cap005251 { cap005251 iff cap005251c }
check CapBenchEquivalent_cap005251 for 4

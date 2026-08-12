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
all u: User | u -> u not in follows
all u: User | u not in u.follows
follows - iden = follows
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

pred cap003885 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((some CapBenchB or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap003885c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv2 and ((some CapBenchB or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003885 { cap003885 iff cap003885c }
check CapBenchEquivalent_cap003885 for 4

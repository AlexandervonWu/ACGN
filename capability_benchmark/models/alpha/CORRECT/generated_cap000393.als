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
all x : User | x not in x.follows
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

pred cap000393 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv2 and ((some CapBenchB or some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap000393c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv2 and ((some CapBenchB or some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000393 { cap000393 iff cap000393c }
check CapBenchEquivalent_cap000393 for 4

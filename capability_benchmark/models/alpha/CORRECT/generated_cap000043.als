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
all x : User | x -> x not in follows
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

pred cap000043 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv2 and ((no CapBenchB or some capBenchS) and some CapBenchA))) }
pred cap000043c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv2 and ((no CapBenchB or some capBenchS) and some CapBenchA))) }
assert CapBenchEquivalent_cap000043 { cap000043 iff cap000043c }
check CapBenchEquivalent_cap000043 for 4

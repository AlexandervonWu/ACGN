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

pred cap000149 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv2 and ((some capBenchS or no CapBenchA) or no CapBenchA))) }
pred cap000149c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv2 and ((some capBenchS or no CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap000149 { cap000149 iff cap000149c }
check CapBenchEquivalent_cap000149 for 4

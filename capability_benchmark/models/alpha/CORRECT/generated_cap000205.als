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

pred inv1 {
all x: Photo | one posts.x
}

pred inv1c {
	all p : Photo | one posts.p
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000205 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv1 and ((some capBenchS or some CapBenchB) or no CapBenchB))) }
pred cap000205c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv1 and ((some capBenchS or some CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap000205 { cap000205 iff cap000205c }
check CapBenchEquivalent_cap000205 for 4

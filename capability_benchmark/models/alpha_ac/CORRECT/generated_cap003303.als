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

pred cap003303 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchR)) and ((some capBenchR and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap003303c { all renamed: CapBenchA | (((some capBenchR and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchR))) }
assert CapBenchEquivalent_cap003303 { cap003303 iff cap003303c }
check CapBenchEquivalent_cap003303 for 4

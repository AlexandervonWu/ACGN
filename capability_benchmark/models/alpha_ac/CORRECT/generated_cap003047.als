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

pred cap003047 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchA)) and ((some capBenchR and no CapBenchB) or no CapBenchB)) }
pred cap003047c { all renamed: CapBenchA | (((some capBenchR and no CapBenchB) or no CapBenchB) and renamed->renamed in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchA))) }
assert CapBenchEquivalent_cap003047 { cap003047 iff cap003047c }
check CapBenchEquivalent_cap003047 for 4

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
all x : Photo | one posts.x
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

pred cap003784 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((some capBenchR and no CapBenchB) or some capBenchR))) }
pred cap003784c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv1 and ((some capBenchR and no CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap003784 { cap003784 iff cap003784c }
check CapBenchEquivalent_cap003784 for 4

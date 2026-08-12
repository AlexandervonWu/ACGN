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
all y : univ | y in Photo implies some x : User | x->y in posts
all p : Photo | all x, y : User | x->p in posts and y->p in posts implies x = y
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

pred cap003769 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((some capBenchS or some CapBenchB) or some capBenchR))) }
pred cap003769c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv1 and ((some capBenchS or some CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap003769 { cap003769 iff cap003769c }
check CapBenchEquivalent_cap003769 for 4

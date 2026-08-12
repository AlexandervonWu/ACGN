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

pred cap005336 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((some CapBenchA and no CapBenchA) or some capBenchS)) and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap005336c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv1 and ((some CapBenchA and no CapBenchA) or some capBenchS)))) }
assert CapBenchEquivalent_cap005336 { cap005336 iff cap005336c }
check CapBenchEquivalent_cap005336 for 4

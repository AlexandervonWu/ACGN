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

pred inv3 {
all u : User | all p : Photo | p in u.sees implies p in u.follows.posts or p in Ad
}

pred inv3c {
	all p : User | p.sees - Ad in p.follows.posts
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005103 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchB)) and ((some capBenchR and no CapBenchA) or some capBenchR))) }
pred cap005103c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchR and no CapBenchA) or some capBenchR)) or (not (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchB)))) }
assert CapBenchEquivalent_cap005103 { cap005103 iff cap005103c }
check CapBenchEquivalent_cap005103 for 4

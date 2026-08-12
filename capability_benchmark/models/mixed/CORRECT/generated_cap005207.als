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
all p: Photo | one u: User| p in u.posts
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

pred cap005207 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchB)) and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
pred cap005207c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) or (not (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchB)))) }
assert CapBenchEquivalent_cap005207 { cap005207 iff cap005207c }
check CapBenchEquivalent_cap005207 for 4

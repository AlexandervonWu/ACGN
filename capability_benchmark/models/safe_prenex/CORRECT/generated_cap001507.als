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
all p : Photo | p in User.posts
all p : Photo | one u : User | p in u.posts
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

pred cap001507 { ((all x: CapBenchA | x->x in capBenchR) or (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchA))) }
pred cap001507c { (all x: CapBenchA | (x->x in capBenchR or (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchA)))) }
assert CapBenchEquivalent_cap001507 { cap001507 iff cap001507c }
check CapBenchEquivalent_cap001507 for 4

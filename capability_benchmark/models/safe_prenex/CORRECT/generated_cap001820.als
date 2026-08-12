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

pred cap001820 { ((some x: CapBenchA | x->x in capBenchR) and (inv1 and ((some CapBenchA and some CapBenchA) or some capBenchS))) }
pred cap001820c { (some x: CapBenchA | (x->x in capBenchR and (inv1 and ((some CapBenchA and some CapBenchA) or some capBenchS)))) }
assert CapBenchEquivalent_cap001820 { cap001820 iff cap001820c }
check CapBenchEquivalent_cap001820 for 4

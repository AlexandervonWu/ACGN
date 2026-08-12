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

pred cap001948 { ((some x: CapBenchA | x->x in capBenchR) and (inv1 and ((some CapBenchA and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap001948c { (some x: CapBenchA | (x->x in capBenchR and (inv1 and ((some CapBenchA and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap001948 { cap001948 iff cap001948c }
check CapBenchEquivalent_cap001948 for 4

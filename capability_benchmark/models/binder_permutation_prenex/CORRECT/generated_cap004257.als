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

pred cap004257 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((some CapBenchB or some CapBenchA) or some capBenchR))) }
pred cap004257c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((some CapBenchB or some CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap004257 { cap004257 iff cap004257c }
check CapBenchEquivalent_cap004257 for 4

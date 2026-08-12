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
all p:Photo|one u: User| p in u.posts
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

pred cap003380 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) and ((some CapBenchB or some capBenchS) or some CapBenchA)) }
pred cap003380c { all renamed: CapBenchA | (((some CapBenchB or some capBenchS) or some CapBenchA) and renamed->renamed in capBenchR and (inv1 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap003380 { cap003380 iff cap003380c }
check CapBenchEquivalent_cap003380 for 4

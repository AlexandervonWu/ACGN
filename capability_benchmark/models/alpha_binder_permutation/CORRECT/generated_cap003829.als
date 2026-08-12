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
all p:Photo| one u:User| u->p in posts
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

pred cap003829 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((some CapBenchB or some CapBenchB) or some capBenchS))) }
pred cap003829c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv1 and ((some CapBenchB or some CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap003829 { cap003829 iff cap003829c }
check CapBenchEquivalent_cap003829 for 4

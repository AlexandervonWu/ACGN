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

pred cap003680 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA))) }
pred cap003680c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv1 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA))) }
assert CapBenchEquivalent_cap003680 { cap003680 iff cap003680c }
check CapBenchEquivalent_cap003680 for 4

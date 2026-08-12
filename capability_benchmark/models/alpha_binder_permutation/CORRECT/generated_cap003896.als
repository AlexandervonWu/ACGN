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

pred inv4 {
all u : User | some u.posts & Ad implies (u.posts & Ad = u.posts)
}

pred inv4c {
	all u : posts.Ad | u.posts in Ad
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003896 { all x, y: CapBenchA | (x->y in capBenchR and (inv4 and ((some capBenchR and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap003896c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv4 and ((some capBenchR and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003896 { cap003896 iff cap003896c }
check CapBenchEquivalent_cap003896 for 4

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
no (posts.Ad & posts.(Photo-Ad))
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

pred cap003756 { all x, y: CapBenchA | (x->y in capBenchR and (inv4 and ((some CapBenchA and some CapBenchA) or some capBenchR))) }
pred cap003756c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv4 and ((some CapBenchA and some CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap003756 { cap003756 iff cap003756c }
check CapBenchEquivalent_cap003756 for 4

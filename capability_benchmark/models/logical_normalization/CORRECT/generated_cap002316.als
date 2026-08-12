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

pred cap002316 { not (all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchR)))) }
pred cap002316c { some x: CapBenchA | not (x->x in capBenchR and (inv4 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap002316 { cap002316 iff cap002316c }
check CapBenchEquivalent_cap002316 for 4

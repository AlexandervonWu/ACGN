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

pred cap001664 { ((some x: CapBenchA | x->x in capBenchR) and (inv4 and ((some capBenchR and some capBenchR) or no CapBenchA))) }
pred cap001664c { (some x: CapBenchA | (x->x in capBenchR and (inv4 and ((some capBenchR and some capBenchR) or no CapBenchA)))) }
assert CapBenchEquivalent_cap001664 { cap001664 iff cap001664c }
check CapBenchEquivalent_cap001664 for 4

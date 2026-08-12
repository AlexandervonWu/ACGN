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

pred cap000608 { ((inv4 and ((some capBenchR and some capBenchS) or some CapBenchB)) and ((some CapBenchB or no CapBenchB) or some capBenchR) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap000608c { (((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and (inv4 and ((some capBenchR and some capBenchS) or some CapBenchB)) and ((some CapBenchB or no CapBenchB) or some capBenchR)) }
assert CapBenchEquivalent_cap000608 { cap000608 iff cap000608c }
check CapBenchEquivalent_cap000608 for 4

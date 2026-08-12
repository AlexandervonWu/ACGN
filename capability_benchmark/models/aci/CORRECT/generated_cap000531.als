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

pred cap000531 { ((inv4 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchA)) or ((some capBenchR and some CapBenchB) or no CapBenchB) or ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchS)) }
pred cap000531c { (((some capBenchR and some CapBenchB) or no CapBenchB) or ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchS) or (inv4 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap000531 { cap000531 iff cap000531c }
check CapBenchEquivalent_cap000531 for 4

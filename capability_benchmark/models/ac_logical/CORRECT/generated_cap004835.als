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

pred cap004835 { not ((inv4 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some capBenchS)) and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap004835c { ((not ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv4 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some capBenchS)))) }
assert CapBenchEquivalent_cap004835 { cap004835 iff cap004835c }
check CapBenchEquivalent_cap004835 for 4

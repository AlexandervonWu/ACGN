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

pred cap002471 { ((inv4 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) iff ((some capBenchR and some CapBenchA) or no CapBenchA)) }
pred cap002471c { (((not (inv4 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) or ((some capBenchR and some CapBenchA) or no CapBenchA)) and ((not ((some capBenchR and some CapBenchA) or no CapBenchA)) or (inv4 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap002471 { cap002471 iff cap002471c }
check CapBenchEquivalent_cap002471 for 4

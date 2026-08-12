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

pred cap003459 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((no CapBenchB or some CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)) }
pred cap003459c { all renamed: CapBenchA | (((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB) and renamed->renamed in capBenchR and (inv4 and ((no CapBenchB or some CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003459 { cap003459 iff cap003459c }
check CapBenchEquivalent_cap003459 for 4

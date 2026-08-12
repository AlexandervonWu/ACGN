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

pred cap003235 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((no CapBenchB or some capBenchS) and no CapBenchB)) and ((some CapBenchA and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003235c { all renamed: CapBenchA | (((some CapBenchA and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv4 and ((no CapBenchB or some capBenchS) and no CapBenchB))) }
assert CapBenchEquivalent_cap003235 { cap003235 iff cap003235c }
check CapBenchEquivalent_cap003235 for 4

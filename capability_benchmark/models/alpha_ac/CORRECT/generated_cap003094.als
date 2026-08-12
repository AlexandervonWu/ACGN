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

pred cap003094 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchB)) and ((no CapBenchB or some CapBenchB) and some capBenchR)) }
pred cap003094c { all renamed: CapBenchA | (((no CapBenchB or some CapBenchB) and some capBenchR) and renamed->renamed in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap003094 { cap003094 iff cap003094c }
check CapBenchEquivalent_cap003094 for 4

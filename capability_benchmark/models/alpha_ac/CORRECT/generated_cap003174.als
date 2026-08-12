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
all u:User | all p:Photo | ((p in u.posts) and (p in Ad)) implies u.posts in Ad
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

pred cap003174 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchA)) and ((no CapBenchB or no CapBenchB) and some capBenchS)) }
pred cap003174c { all renamed: CapBenchA | (((no CapBenchB or no CapBenchB) and some capBenchS) and renamed->renamed in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchA))) }
assert CapBenchEquivalent_cap003174 { cap003174 iff cap003174c }
check CapBenchEquivalent_cap003174 for 4

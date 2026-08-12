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

pred cap003246 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB)) and ((no CapBenchB or some capBenchR) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003246c { all renamed: CapBenchA | (((no CapBenchB or some capBenchR) and capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB))) }
assert CapBenchEquivalent_cap003246 { cap003246 iff cap003246c }
check CapBenchEquivalent_cap003246 for 4

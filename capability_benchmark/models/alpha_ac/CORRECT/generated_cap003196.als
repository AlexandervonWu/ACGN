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

pred cap003196 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some capBenchR and some CapBenchA) or no CapBenchB)) and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) }
pred cap003196c { all renamed: CapBenchA | (((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS) and renamed->renamed in capBenchR and (inv4 and ((some capBenchR and some CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap003196 { cap003196 iff cap003196c }
check CapBenchEquivalent_cap003196 for 4

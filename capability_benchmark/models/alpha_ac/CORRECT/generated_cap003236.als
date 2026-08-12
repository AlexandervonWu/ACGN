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

pred cap003236 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some capBenchR and some capBenchS) or no CapBenchB)) and ((some CapBenchB or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003236c { all renamed: CapBenchA | (((some CapBenchB or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv4 and ((some capBenchR and some capBenchS) or no CapBenchB))) }
assert CapBenchEquivalent_cap003236 { cap003236 iff cap003236c }
check CapBenchEquivalent_cap003236 for 4

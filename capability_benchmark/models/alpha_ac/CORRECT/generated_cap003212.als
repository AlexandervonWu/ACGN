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
all u1 : User | all ph : Photo |
ph in u1.posts and ph in Ad implies u1.posts in Ad
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

pred cap003212 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some capBenchR and no CapBenchA) or no CapBenchB)) and ((some CapBenchB or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003212c { all renamed: CapBenchA | (((some CapBenchB or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv4 and ((some capBenchR and no CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap003212 { cap003212 iff cap003212c }
check CapBenchEquivalent_cap003212 for 4

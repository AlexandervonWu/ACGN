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

pred inv3 {
all u : User, p : Photo | p in u.sees => p in u.follows.posts or p in Ad
}

pred inv3c {
	all p : User | p.sees - Ad in p.follows.posts
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003194 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((no CapBenchA and some CapBenchA) and no CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchS)) }
pred cap003194c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchS) and renamed->renamed in capBenchR and (inv3 and ((no CapBenchA and some CapBenchA) and no CapBenchB))) }
assert CapBenchEquivalent_cap003194 { cap003194 iff cap003194c }
check CapBenchEquivalent_cap003194 for 4

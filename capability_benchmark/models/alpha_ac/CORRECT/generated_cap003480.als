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
all u:User, p:Photo| p in u.posts and p in Ad implies u.posts in Ad
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

pred cap003480 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some CapBenchA and some capBenchR) or CapBenchA in CapBenchA + CapBenchB)) and ((some capBenchS or some CapBenchB) or no CapBenchA)) }
pred cap003480c { all renamed: CapBenchA | (((some capBenchS or some CapBenchB) or no CapBenchA) and renamed->renamed in capBenchR and (inv4 and ((some CapBenchA and some capBenchR) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003480 { cap003480 iff cap003480c }
check CapBenchEquivalent_cap003480 for 4

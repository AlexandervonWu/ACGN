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

pred cap003023 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchA)) and ((some capBenchR and some CapBenchA) or no CapBenchB)) }
pred cap003023c { all renamed: CapBenchA | (((some capBenchR and some CapBenchA) or no CapBenchB) and renamed->renamed in capBenchR and (inv4 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchA))) }
assert CapBenchEquivalent_cap003023 { cap003023 iff cap003023c }
check CapBenchEquivalent_cap003023 for 4

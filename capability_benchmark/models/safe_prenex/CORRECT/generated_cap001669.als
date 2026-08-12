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

pred cap001669 { ((all x: CapBenchA | x->x in capBenchR) or (inv4 and ((some CapBenchB or some capBenchS) or no CapBenchA))) }
pred cap001669c { (all x: CapBenchA | (x->x in capBenchR or (inv4 and ((some CapBenchB or some capBenchS) or no CapBenchA)))) }
assert CapBenchEquivalent_cap001669 { cap001669 iff cap001669c }
check CapBenchEquivalent_cap001669 for 4

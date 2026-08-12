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

pred cap001844 { ((some x: CapBenchA | x->x in capBenchR) and (inv4 and ((some CapBenchA and no CapBenchB) or some capBenchS))) }
pred cap001844c { (some x: CapBenchA | (x->x in capBenchR and (inv4 and ((some CapBenchA and no CapBenchB) or some capBenchS)))) }
assert CapBenchEquivalent_cap001844 { cap001844 iff cap001844c }
check CapBenchEquivalent_cap001844 for 4

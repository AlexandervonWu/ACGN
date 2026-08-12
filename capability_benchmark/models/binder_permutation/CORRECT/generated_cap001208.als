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
all u:User, a:Ad| u->a in posts implies u.posts in Ad
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

pred cap001208 { all x, y: CapBenchA | (x->y in capBenchR and (inv4 and ((some CapBenchA and no CapBenchA) or no CapBenchB))) }
pred cap001208c { all a, b: CapBenchA | (b->a in capBenchR and (inv4 and ((some CapBenchA and no CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap001208 { cap001208 iff cap001208c }
check CapBenchEquivalent_cap001208 for 4

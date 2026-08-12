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
all u:User, p:Photo | p in Ad and u in posts.p implies (all ph:Photo | u in posts.ph implies ph in Ad)
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

pred cap001522 { ((some x: CapBenchA | x->x in capBenchR) and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchA))) }
pred cap001522c { (some x: CapBenchA | (x->x in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchA)))) }
assert CapBenchEquivalent_cap001522 { cap001522 iff cap001522c }
check CapBenchEquivalent_cap001522 for 4

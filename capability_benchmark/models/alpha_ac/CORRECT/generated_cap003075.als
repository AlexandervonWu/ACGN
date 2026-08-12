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

pred cap003075 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((no CapBenchB or some CapBenchB) and some CapBenchB)) and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)) }
pred cap003075c { all renamed: CapBenchA | (((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchB) and renamed->renamed in capBenchR and (inv4 and ((no CapBenchB or some CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap003075 { cap003075 iff cap003075c }
check CapBenchEquivalent_cap003075 for 4

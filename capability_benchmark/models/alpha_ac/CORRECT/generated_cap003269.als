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

pred cap003269 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some capBenchS or some CapBenchB) or some capBenchR)) and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003269c { all renamed: CapBenchA | (((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv4 and ((some capBenchS or some CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap003269 { cap003269 iff cap003269c }
check CapBenchEquivalent_cap003269 for 4

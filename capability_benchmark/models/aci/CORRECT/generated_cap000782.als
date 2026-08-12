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

pred cap000782 { ((inv4 and ((no CapBenchA and no CapBenchB) and some capBenchR)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)) }
pred cap000782c { (((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB) and (inv4 and ((no CapBenchA and no CapBenchB) and some capBenchR)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) }
assert CapBenchEquivalent_cap000782 { cap000782 iff cap000782c }
check CapBenchEquivalent_cap000782 for 4

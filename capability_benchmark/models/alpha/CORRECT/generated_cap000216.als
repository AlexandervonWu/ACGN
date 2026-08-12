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

pred cap000216 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv4 and ((some CapBenchA and no CapBenchB) or no CapBenchB))) }
pred cap000216c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv4 and ((some CapBenchA and no CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap000216 { cap000216 iff cap000216c }
check CapBenchEquivalent_cap000216 for 4

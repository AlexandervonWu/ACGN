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
all u: User, a: Ad | a in u.posts => u.posts in Ad
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

pred cap000206 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchB))) }
pred cap000206c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap000206 { cap000206 iff cap000206c }
check CapBenchEquivalent_cap000206 for 4

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

pred cap000052 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv4 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) }
pred cap000052c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv4 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) }
assert CapBenchEquivalent_cap000052 { cap000052 iff cap000052c }
check CapBenchEquivalent_cap000052 for 4

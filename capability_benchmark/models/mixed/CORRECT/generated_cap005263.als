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

pred cap005263 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchR)) and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap005263c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv4 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchR)))) }
assert CapBenchEquivalent_cap005263 { cap005263 iff cap005263c }
check CapBenchEquivalent_cap005263 for 4

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

pred cap005033 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((some CapBenchB or some capBenchR) or some CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchB))) }
pred cap005033c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchB)) or (not (inv4 and ((some CapBenchB or some capBenchR) or some CapBenchA)))) }
assert CapBenchEquivalent_cap005033 { cap005033 iff cap005033c }
check CapBenchEquivalent_cap005033 for 4

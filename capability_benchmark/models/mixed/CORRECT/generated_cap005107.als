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

pred cap005107 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((no CapBenchB or some capBenchS) and some CapBenchB)) and ((some CapBenchA and no CapBenchB) or some capBenchR))) }
pred cap005107c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and no CapBenchB) or some capBenchR)) or (not (inv4 and ((no CapBenchB or some capBenchS) and some CapBenchB)))) }
assert CapBenchEquivalent_cap005107 { cap005107 iff cap005107c }
check CapBenchEquivalent_cap005107 for 4

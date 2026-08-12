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
all u:User | some u.posts & Ad implies u.posts in Ad
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

pred cap005045 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((some capBenchS or some capBenchS) or some CapBenchA)) and ((no CapBenchA and no CapBenchB) and no CapBenchB))) }
pred cap005045c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and no CapBenchB) and no CapBenchB)) or (not (inv4 and ((some capBenchS or some capBenchS) or some CapBenchA)))) }
assert CapBenchEquivalent_cap005045 { cap005045 iff cap005045c }
check CapBenchEquivalent_cap005045 for 4

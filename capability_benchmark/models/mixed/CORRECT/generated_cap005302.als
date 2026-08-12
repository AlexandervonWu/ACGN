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

pred cap005302 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchR)) and ((no CapBenchB or no CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap005302c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchB or no CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchR)))) }
assert CapBenchEquivalent_cap005302 { cap005302 iff cap005302c }
check CapBenchEquivalent_cap005302 for 4

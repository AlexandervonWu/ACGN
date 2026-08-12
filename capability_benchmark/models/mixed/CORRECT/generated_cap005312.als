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
no (posts.Ad & posts.(Photo-Ad))
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

pred cap005312 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchR)) and ((some capBenchS or some capBenchR) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap005312c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or some capBenchR) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv4 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchR)))) }
assert CapBenchEquivalent_cap005312 { cap005312 iff cap005312c }
check CapBenchEquivalent_cap005312 for 4

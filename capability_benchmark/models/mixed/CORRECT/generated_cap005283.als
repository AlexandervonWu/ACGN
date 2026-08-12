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
all u: User | (u.posts in Ad) or (u.posts in Photo-Ad)
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

pred cap005283 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((no CapBenchB or no CapBenchB) and some capBenchR)) and ((some CapBenchA and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap005283c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv4 and ((no CapBenchB or no CapBenchB) and some capBenchR)))) }
assert CapBenchEquivalent_cap005283 { cap005283 iff cap005283c }
check CapBenchEquivalent_cap005283 for 4

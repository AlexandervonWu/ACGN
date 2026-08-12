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

pred cap005164 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((some capBenchR and some capBenchR) or no CapBenchA)) and ((some CapBenchB or no CapBenchA) or some capBenchS))) }
pred cap005164c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or no CapBenchA) or some capBenchS)) or (not (inv4 and ((some capBenchR and some capBenchR) or no CapBenchA)))) }
assert CapBenchEquivalent_cap005164 { cap005164 iff cap005164c }
check CapBenchEquivalent_cap005164 for 4

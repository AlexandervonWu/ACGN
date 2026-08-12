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

pred cap005005 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((some capBenchS or some CapBenchA) or some CapBenchA)) and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA))) }
pred cap005005c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)) or (not (inv4 and ((some capBenchS or some CapBenchA) or some CapBenchA)))) }
assert CapBenchEquivalent_cap005005 { cap005005 iff cap005005c }
check CapBenchEquivalent_cap005005 for 4

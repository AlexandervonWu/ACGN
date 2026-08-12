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

pred inv8 {
all u: User, a: Ad | a in u.sees => a in u.follows.posts or a in u.suggested.posts
}

pred inv8c {
	all u : User, p : u.sees & Ad | p in u.(follows+suggested).posts
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005075 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv8 and ((no CapBenchB or some CapBenchB) and some CapBenchB)) and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchB))) }
pred cap005075c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)) or (not (inv8 and ((no CapBenchB or some CapBenchB) and some CapBenchB)))) }
assert CapBenchEquivalent_cap005075 { cap005075 iff cap005075c }
check CapBenchEquivalent_cap005075 for 4

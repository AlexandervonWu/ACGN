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

pred cap005027 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv8 and ((no CapBenchB or no CapBenchB) and some CapBenchA)) and ((some CapBenchA and some CapBenchB) or no CapBenchB))) }
pred cap005027c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and some CapBenchB) or no CapBenchB)) or (not (inv8 and ((no CapBenchB or no CapBenchB) and some CapBenchA)))) }
assert CapBenchEquivalent_cap005027 { cap005027 iff cap005027c }
check CapBenchEquivalent_cap005027 for 4

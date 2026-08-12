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

pred cap001604 { ((some x: CapBenchA | x->x in capBenchR) and (inv8 and ((some CapBenchA and some capBenchS) or some CapBenchB))) }
pred cap001604c { (some x: CapBenchA | (x->x in capBenchR and (inv8 and ((some CapBenchA and some capBenchS) or some CapBenchB)))) }
assert CapBenchEquivalent_cap001604 { cap001604 iff cap001604c }
check CapBenchEquivalent_cap001604 for 4

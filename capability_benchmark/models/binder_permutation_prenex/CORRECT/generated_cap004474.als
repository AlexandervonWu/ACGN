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

pred cap004474 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv8 and ((no CapBenchA and no CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap004474c { some a, b: CapBenchA | (b->a in capBenchR and (inv8 and ((no CapBenchA and no CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap004474 { cap004474 iff cap004474c }
check CapBenchEquivalent_cap004474 for 4

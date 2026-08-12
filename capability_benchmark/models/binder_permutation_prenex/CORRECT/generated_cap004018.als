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

pred inv3 {
all u : User, p : Photo | p in u.sees => p in u.follows.posts or p in Ad
}

pred inv3c {
	all p : User | p.sees - Ad in p.follows.posts
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004018 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv3 and ((no CapBenchA and no CapBenchA) and some CapBenchA))) }
pred cap004018c { some a, b: CapBenchA | (b->a in capBenchR and (inv3 and ((no CapBenchA and no CapBenchA) and some CapBenchA))) }
assert CapBenchEquivalent_cap004018 { cap004018 iff cap004018c }
check CapBenchEquivalent_cap004018 for 4

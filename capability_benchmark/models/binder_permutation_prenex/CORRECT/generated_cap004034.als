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
all u : User | all p : Photo | p in u.sees implies p in u.follows.posts or p in Ad
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

pred cap004034 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv3 and ((no CapBenchA and some capBenchR) and some CapBenchA))) }
pred cap004034c { some a, b: CapBenchA | (b->a in capBenchR and (inv3 and ((no CapBenchA and some capBenchR) and some CapBenchA))) }
assert CapBenchEquivalent_cap004034 { cap004034 iff cap004034c }
check CapBenchEquivalent_cap004034 for 4

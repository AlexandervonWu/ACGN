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
all x : User| x.sees- Ad in x.follows.posts
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

pred cap004322 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv3 and ((no CapBenchA and some CapBenchA) and some capBenchS))) }
pred cap004322c { some a, b: CapBenchA | (b->a in capBenchR and (inv3 and ((no CapBenchA and some CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap004322 { cap004322 iff cap004322c }
check CapBenchEquivalent_cap004322 for 4

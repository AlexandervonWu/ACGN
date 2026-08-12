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
all u : User | u.sees - Ad in u.follows.posts
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

pred cap004167 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchA))) }
pred cap004167c { some a, b: CapBenchA | (b->a in capBenchR and (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchA))) }
assert CapBenchEquivalent_cap004167 { cap004167 iff cap004167c }
check CapBenchEquivalent_cap004167 for 4

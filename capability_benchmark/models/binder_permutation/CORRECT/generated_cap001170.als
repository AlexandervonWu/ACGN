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

pred cap001170 { all x, y: CapBenchA | (x->y in capBenchR and (inv3 and ((no CapBenchA and some capBenchS) and no CapBenchA))) }
pred cap001170c { all a, b: CapBenchA | (b->a in capBenchR and (inv3 and ((no CapBenchA and some capBenchS) and no CapBenchA))) }
assert CapBenchEquivalent_cap001170 { cap001170 iff cap001170c }
check CapBenchEquivalent_cap001170 for 4

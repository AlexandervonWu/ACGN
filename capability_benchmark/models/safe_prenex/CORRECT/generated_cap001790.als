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

pred cap001790 { ((some x: CapBenchA | x->x in capBenchR) and (inv3 and ((no CapBenchA and some capBenchR) and some capBenchR))) }
pred cap001790c { (some x: CapBenchA | (x->x in capBenchR and (inv3 and ((no CapBenchA and some capBenchR) and some capBenchR)))) }
assert CapBenchEquivalent_cap001790 { cap001790 iff cap001790c }
check CapBenchEquivalent_cap001790 for 4

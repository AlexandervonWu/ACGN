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

pred cap001560 { ((some x: CapBenchA | x->x in capBenchR) and (inv3 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA))) }
pred cap001560c { (some x: CapBenchA | (x->x in capBenchR and (inv3 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)))) }
assert CapBenchEquivalent_cap001560 { cap001560 iff cap001560c }
check CapBenchEquivalent_cap001560 for 4

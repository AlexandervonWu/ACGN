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

pred cap003773 { all x, y: CapBenchA | (x->y in capBenchR and (inv3 and ((some CapBenchB or no CapBenchA) or some capBenchR))) }
pred cap003773c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv3 and ((some CapBenchB or no CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap003773 { cap003773 iff cap003773c }
check CapBenchEquivalent_cap003773 for 4

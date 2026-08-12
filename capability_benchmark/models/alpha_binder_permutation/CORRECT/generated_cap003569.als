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
all u: User | u.sees in (u.follows.posts + Ad)
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

pred cap003569 { all x, y: CapBenchA | (x->y in capBenchR and (inv3 and ((some capBenchS or some CapBenchA) or some CapBenchB))) }
pred cap003569c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv3 and ((some capBenchS or some CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap003569 { cap003569 iff cap003569c }
check CapBenchEquivalent_cap003569 for 4

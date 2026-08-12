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

pred cap003276 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((some capBenchR and no CapBenchA) or some capBenchR)) and ((some CapBenchB or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap003276c { all renamed: CapBenchA | (((some CapBenchB or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv3 and ((some capBenchR and no CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap003276 { cap003276 iff cap003276c }
check CapBenchEquivalent_cap003276 for 4

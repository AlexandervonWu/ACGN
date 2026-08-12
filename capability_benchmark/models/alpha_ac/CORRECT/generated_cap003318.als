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

pred cap003318 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some capBenchR)) and ((no CapBenchB or some capBenchS) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap003318c { all renamed: CapBenchA | (((no CapBenchB or some capBenchS) and CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap003318 { cap003318 iff cap003318c }
check CapBenchEquivalent_cap003318 for 4

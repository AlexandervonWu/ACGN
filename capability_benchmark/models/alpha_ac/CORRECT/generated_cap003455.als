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
all u : User, p : Photo | p in u.sees => p in u.follows.posts or p in Ad
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

pred cap003455 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)) }
pred cap003455c { all renamed: CapBenchA | (((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB) and renamed->renamed in capBenchR and (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003455 { cap003455 iff cap003455c }
check CapBenchEquivalent_cap003455 for 4

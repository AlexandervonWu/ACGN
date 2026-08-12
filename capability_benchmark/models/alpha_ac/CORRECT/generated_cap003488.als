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

pred cap003488 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((some CapBenchA and some capBenchS) or CapBenchA in CapBenchA + CapBenchB)) and ((some capBenchS or no CapBenchA) or no CapBenchA)) }
pred cap003488c { all renamed: CapBenchA | (((some capBenchS or no CapBenchA) or no CapBenchA) and renamed->renamed in capBenchR and (inv3 and ((some CapBenchA and some capBenchS) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003488 { cap003488 iff cap003488c }
check CapBenchEquivalent_cap003488 for 4

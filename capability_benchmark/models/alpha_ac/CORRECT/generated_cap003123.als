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

pred inv8 {
all u:User,a:Ad | a in u.sees implies (some u1:User | a in u1.posts and u1 in u.follows + u.suggested)
}

pred inv8c {
	all u : User, p : u.sees & Ad | p in u.(follows+suggested).posts
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003123 { all x: CapBenchA | (x->x in capBenchR and (inv8 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchB)) and ((some CapBenchA and some capBenchS) or some capBenchR)) }
pred cap003123c { all renamed: CapBenchA | (((some CapBenchA and some capBenchS) or some capBenchR) and renamed->renamed in capBenchR and (inv8 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap003123 { cap003123 iff cap003123c }
check CapBenchEquivalent_cap003123 for 4

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

pred cap003300 { all x: CapBenchA | (x->x in capBenchR and (inv8 and ((some capBenchR and some capBenchS) or some capBenchR)) and ((some CapBenchB or no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap003300c { all renamed: CapBenchA | (((some CapBenchB or no CapBenchB) or CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv8 and ((some capBenchR and some capBenchS) or some capBenchR))) }
assert CapBenchEquivalent_cap003300 { cap003300 iff cap003300c }
check CapBenchEquivalent_cap003300 for 4

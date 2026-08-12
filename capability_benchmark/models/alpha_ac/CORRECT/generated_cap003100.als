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

pred cap003100 { all x: CapBenchA | (x->x in capBenchR and (inv8 and ((some capBenchR and some capBenchR) or some CapBenchB)) and ((some CapBenchB or no CapBenchA) or some capBenchR)) }
pred cap003100c { all renamed: CapBenchA | (((some CapBenchB or no CapBenchA) or some capBenchR) and renamed->renamed in capBenchR and (inv8 and ((some capBenchR and some capBenchR) or some CapBenchB))) }
assert CapBenchEquivalent_cap003100 { cap003100 iff cap003100c }
check CapBenchEquivalent_cap003100 for 4

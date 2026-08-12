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

pred cap003369 { all x: CapBenchA | (x->x in capBenchR and (inv8 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchA)) }
pred cap003369c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchA) and renamed->renamed in capBenchR and (inv8 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS))) }
assert CapBenchEquivalent_cap003369 { cap003369 iff cap003369c }
check CapBenchEquivalent_cap003369 for 4

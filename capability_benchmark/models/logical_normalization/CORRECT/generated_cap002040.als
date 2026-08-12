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

pred inv4 {
all u : User | some u.posts & Ad implies (u.posts & Ad = u.posts)
}

pred inv4c {
	all u : posts.Ad | u.posts in Ad
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002040 { not (all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some CapBenchA and some capBenchS) or some CapBenchA)))) }
pred cap002040c { some x: CapBenchA | not (x->x in capBenchR and (inv4 and ((some CapBenchA and some capBenchS) or some CapBenchA))) }
assert CapBenchEquivalent_cap002040 { cap002040 iff cap002040c }
check CapBenchEquivalent_cap002040 for 4

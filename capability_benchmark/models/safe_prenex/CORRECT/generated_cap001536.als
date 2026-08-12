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
all u : User | u.posts in Ad or u.posts in Photo - Ad
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

pred cap001536 { ((some x: CapBenchA | x->x in capBenchR) and (inv4 and ((some capBenchR and some capBenchR) or some CapBenchA))) }
pred cap001536c { (some x: CapBenchA | (x->x in capBenchR and (inv4 and ((some capBenchR and some capBenchR) or some CapBenchA)))) }
assert CapBenchEquivalent_cap001536 { cap001536 iff cap001536c }
check CapBenchEquivalent_cap001536 for 4

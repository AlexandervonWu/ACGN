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
all u: User, a: Ad | a in u.posts => u.posts in Ad
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

pred cap001501 { ((all x: CapBenchA | x->x in capBenchR) or (inv4 and ((some CapBenchB or some CapBenchA) or some CapBenchA))) }
pred cap001501c { (all x: CapBenchA | (x->x in capBenchR or (inv4 and ((some CapBenchB or some CapBenchA) or some CapBenchA)))) }
assert CapBenchEquivalent_cap001501 { cap001501 iff cap001501c }
check CapBenchEquivalent_cap001501 for 4

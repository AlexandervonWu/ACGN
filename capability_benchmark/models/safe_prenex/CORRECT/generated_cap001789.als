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
all u:User | all a:Ad | a in u.posts implies u.posts in Ad
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

pred cap001789 { ((all x: CapBenchA | x->x in capBenchR) or (inv4 and ((some CapBenchB or some capBenchR) or some capBenchR))) }
pred cap001789c { (all x: CapBenchA | (x->x in capBenchR or (inv4 and ((some CapBenchB or some capBenchR) or some capBenchR)))) }
assert CapBenchEquivalent_cap001789 { cap001789 iff cap001789c }
check CapBenchEquivalent_cap001789 for 4

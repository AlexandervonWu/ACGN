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
all u1 : User | all ph : Photo |
ph in u1.posts and ph in Ad implies u1.posts in Ad
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

pred cap001350 { all x, y: CapBenchA | (x->y in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchS))) }
pred cap001350c { all a, b: CapBenchA | (b->a in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap001350 { cap001350 iff cap001350c }
check CapBenchEquivalent_cap001350 for 4

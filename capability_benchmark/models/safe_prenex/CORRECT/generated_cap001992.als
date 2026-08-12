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

pred inv1 {
all u:User,u2:User | all p:Photo | p in u.posts and p in u2.posts implies u = u2
all p:Photo | p in User.posts
}

pred inv1c {
	all p : Photo | one posts.p
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001992 { ((some x: CapBenchA | x->x in capBenchR) and (inv1 and ((some capBenchR and some capBenchS) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap001992c { (some x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchR and some capBenchS) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap001992 { cap001992 iff cap001992c }
check CapBenchEquivalent_cap001992 for 4

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

pred cap002155 { no x: CapBenchA | (x->x in capBenchR and (inv1 and ((no CapBenchB or no CapBenchB) and no CapBenchA))) }
pred cap002155c { all x: CapBenchA | not (x->x in capBenchR and (inv1 and ((no CapBenchB or no CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap002155 { cap002155 iff cap002155c }
check CapBenchEquivalent_cap002155 for 4

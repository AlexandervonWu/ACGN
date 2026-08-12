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

pred cap004245 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB))) }
pred cap004245c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB))) }
assert CapBenchEquivalent_cap004245 { cap004245 iff cap004245c }
check CapBenchEquivalent_cap004245 for 4

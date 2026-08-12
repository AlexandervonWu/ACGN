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
all p : Photo | p in User.posts
all p : Photo | one u : User | p in u.posts
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

pred cap000197 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv1 and ((some capBenchS or some CapBenchA) or no CapBenchB))) }
pred cap000197c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv1 and ((some capBenchS or some CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap000197 { cap000197 iff cap000197c }
check CapBenchEquivalent_cap000197 for 4

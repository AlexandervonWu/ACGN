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
all y : univ | y in Photo implies some x : User | x->y in posts
all p : Photo | all x, y : User | x->p in posts and y->p in posts implies x = y
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

pred cap001698 { ((some x: CapBenchA | x->x in capBenchR) and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and no CapBenchB))) }
pred cap001698c { (some x: CapBenchA | (x->x in capBenchR and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and no CapBenchB)))) }
assert CapBenchEquivalent_cap001698 { cap001698 iff cap001698c }
check CapBenchEquivalent_cap001698 for 4

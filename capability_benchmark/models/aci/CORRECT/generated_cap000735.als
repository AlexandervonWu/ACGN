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

pred cap000735 { ((inv1 and ((no CapBenchB or some capBenchS) and no CapBenchB)) or ((some CapBenchA and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)) or ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchB)) }
pred cap000735c { (((some CapBenchA and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)) or ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchB) or (inv1 and ((no CapBenchB or some capBenchS) and no CapBenchB))) }
assert CapBenchEquivalent_cap000735 { cap000735 iff cap000735c }
check CapBenchEquivalent_cap000735 for 4

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

pred cap003069 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchS or some CapBenchA) or some CapBenchB)) and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB)) }
pred cap003069c { all renamed: CapBenchA | (((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB) and renamed->renamed in capBenchR and (inv1 and ((some capBenchS or some CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap003069 { cap003069 iff cap003069c }
check CapBenchEquivalent_cap003069 for 4

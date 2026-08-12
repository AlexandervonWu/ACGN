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
all x : Photo | one posts.x
all x : Photo | one posts.x
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

pred cap001193 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv1 and ((some CapBenchB or some CapBenchA) or no CapBenchB))) }
pred cap001193c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv1 and ((some CapBenchB or some CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap001193 { cap001193 iff cap001193c }
check CapBenchEquivalent_cap001193 for 4

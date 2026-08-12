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

pred cap004189 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA))) }
pred cap004189c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap004189 { cap004189 iff cap004189c }
check CapBenchEquivalent_cap004189 for 4

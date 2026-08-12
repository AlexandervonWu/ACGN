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

pred cap003012 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchR and some CapBenchB) or some CapBenchA)) and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)) }
pred cap003012c { all renamed: CapBenchA | (((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA) and renamed->renamed in capBenchR and (inv1 and ((some capBenchR and some CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap003012 { cap003012 iff cap003012c }
check CapBenchEquivalent_cap003012 for 4

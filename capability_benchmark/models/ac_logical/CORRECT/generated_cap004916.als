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

pred cap004916 { not ((inv1 and ((some CapBenchA and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))) and ((some capBenchS or some CapBenchB) or some CapBenchB)) }
pred cap004916c { ((not ((some capBenchS or some CapBenchB) or some CapBenchB)) or (not (inv1 and ((some CapBenchA and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004916 { cap004916 iff cap004916c }
check CapBenchEquivalent_cap004916 for 4

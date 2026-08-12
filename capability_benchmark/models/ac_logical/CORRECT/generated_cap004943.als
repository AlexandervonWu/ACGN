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

pred inv3 {
all p: Photo - Ad, u1: User | some u2: User | u1->p in sees => u2->p in posts and u1->u2 in follows
}

pred inv3c {
	all p : User | p.sees - Ad in p.follows.posts
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004943 { not ((inv3 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchA and some capBenchS) or some CapBenchB)) }
pred cap004943c { ((not ((some CapBenchA and some capBenchS) or some CapBenchB)) or (not (inv3 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004943 { cap004943 iff cap004943c }
check CapBenchEquivalent_cap004943 for 4

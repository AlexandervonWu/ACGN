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

pred inv6 {
all d : Day, i : Influencer | some p : Photo | i->p in posts and p->d in date
}

pred inv6c {
	all i : Influencer, d : Day | some i.posts & date.d
}

check correct { inv6 <=> inv6c}
pred under { inv6 and !inv6c}
pred over { !inv6 and inv6c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004976 { not ((inv6 and ((some capBenchR and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchB or some CapBenchB) or no CapBenchA)) }
pred cap004976c { ((not ((some CapBenchB or some CapBenchB) or no CapBenchA)) or (not (inv6 and ((some capBenchR and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004976 { cap004976 iff cap004976c }
check CapBenchEquivalent_cap004976 for 4

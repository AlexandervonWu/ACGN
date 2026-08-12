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

pred cap002889 { not (((inv6 and ((some capBenchS or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) since (((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA))) }
pred cap002889c { ((not (inv6 and ((some capBenchS or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) triggered (not ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA))) }
assert CapBenchEquivalent_cap002889 { cap002889 iff cap002889c }
check CapBenchEquivalent_cap002889 for 4

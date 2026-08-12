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

pred cap002587 { not once ((inv6 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchB))) }
pred cap002587c { historically (not (inv6 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchB))) }
assert CapBenchEquivalent_cap002587 { cap002587 iff cap002587c }
check CapBenchEquivalent_cap002587 for 4

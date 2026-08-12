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

pred cap002337 { not ((inv6 and ((some CapBenchB or no CapBenchA) or some capBenchS)) and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap002337c { ((not (inv6 and ((some CapBenchB or no CapBenchA) or some capBenchS))) or (not ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002337 { cap002337 iff cap002337c }
check CapBenchEquivalent_cap002337 for 4

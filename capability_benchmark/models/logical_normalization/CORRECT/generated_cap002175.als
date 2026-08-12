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
all i : Influencer | all d : Day | some p : Photo | d = p.date and p in i.posts
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

pred cap002175 { not ((inv6 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchA)) and ((some capBenchR and no CapBenchB) or some capBenchS)) }
pred cap002175c { ((not (inv6 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchA))) or (not ((some capBenchR and no CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap002175 { cap002175 iff cap002175c }
check CapBenchEquivalent_cap002175 for 4

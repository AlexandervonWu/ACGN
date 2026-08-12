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

pred cap002464 { ((inv6 and ((some CapBenchA and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) implies ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)) }
pred cap002464c { ((not (inv6 and ((some CapBenchA and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) or ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)) }
assert CapBenchEquivalent_cap002464 { cap002464 iff cap002464c }
check CapBenchEquivalent_cap002464 for 4

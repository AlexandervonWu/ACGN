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
all d : Day | all i : Influencer |  d in i.posts.date
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

pred cap004723 { not ((inv6 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchB)) and ((some capBenchR and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004723c { ((not ((some capBenchR and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv6 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchB)))) }
assert CapBenchEquivalent_cap004723 { cap004723 iff cap004723c }
check CapBenchEquivalent_cap004723 for 4

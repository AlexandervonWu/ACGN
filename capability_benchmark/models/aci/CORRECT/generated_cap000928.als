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

pred cap000928 { (inv6 and ((some capBenchR and some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap000928c { ((inv6 and ((some capBenchR and some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))) and (inv6 and ((some capBenchR and some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000928 { cap000928 iff cap000928c }
check CapBenchEquivalent_cap000928 for 4

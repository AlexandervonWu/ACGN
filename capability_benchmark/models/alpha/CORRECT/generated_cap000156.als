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

pred cap000156 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv6 and ((some capBenchR and no CapBenchB) or no CapBenchA))) }
pred cap000156c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv6 and ((some capBenchR and no CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap000156 { cap000156 iff cap000156c }
check CapBenchEquivalent_cap000156 for 4

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

pred cap000984 { (some ((CapBenchA.capBenchR).capBenchR) and (inv6 and ((some capBenchR and some capBenchR) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap000984c { (some (CapBenchA.(capBenchR.capBenchR)) and (inv6 and ((some capBenchR and some capBenchR) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap000984 { cap000984 iff cap000984c }
check CapBenchEquivalent_cap000984 for 4

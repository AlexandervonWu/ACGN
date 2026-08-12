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

pred cap002165 { ((inv6 and ((some capBenchS or some capBenchR) or no CapBenchA)) iff ((no CapBenchA and no CapBenchA) and some capBenchS)) }
pred cap002165c { (((not (inv6 and ((some capBenchS or some capBenchR) or no CapBenchA))) or ((no CapBenchA and no CapBenchA) and some capBenchS)) and ((not ((no CapBenchA and no CapBenchA) and some capBenchS)) or (inv6 and ((some capBenchS or some capBenchR) or no CapBenchA)))) }
assert CapBenchEquivalent_cap002165 { cap002165 iff cap002165c }
check CapBenchEquivalent_cap002165 for 4

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
all i : Influencer, d : Day | d in i.posts.date
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

pred cap002164 { ((inv6 and ((some capBenchR and some capBenchR) or no CapBenchA)) implies ((some CapBenchB or no CapBenchA) or some capBenchS)) }
pred cap002164c { ((not (inv6 and ((some capBenchR and some capBenchR) or no CapBenchA))) or ((some CapBenchB or no CapBenchA) or some capBenchS)) }
assert CapBenchEquivalent_cap002164 { cap002164 iff cap002164c }
check CapBenchEquivalent_cap002164 for 4

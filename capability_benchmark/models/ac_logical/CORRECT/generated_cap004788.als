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

pred cap004788 { not ((inv6 and ((some CapBenchA and some capBenchR) or some capBenchR)) and ((some capBenchS or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap004788c { ((not ((some capBenchS or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv6 and ((some CapBenchA and some capBenchR) or some capBenchR)))) }
assert CapBenchEquivalent_cap004788 { cap004788 iff cap004788c }
check CapBenchEquivalent_cap004788 for 4

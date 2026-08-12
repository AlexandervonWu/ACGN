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

pred cap001529 { ((all x: CapBenchA | x->x in capBenchR) or (inv6 and ((some capBenchS or no CapBenchB) or some CapBenchA))) }
pred cap001529c { (all x: CapBenchA | (x->x in capBenchR or (inv6 and ((some capBenchS or no CapBenchB) or some CapBenchA)))) }
assert CapBenchEquivalent_cap001529 { cap001529 iff cap001529c }
check CapBenchEquivalent_cap001529 for 4

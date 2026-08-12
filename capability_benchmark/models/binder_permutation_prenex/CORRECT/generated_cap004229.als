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

pred cap004229 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv6 and ((some capBenchS or some capBenchR) or no CapBenchB))) }
pred cap004229c { some a, b: CapBenchA | (b->a in capBenchR and (inv6 and ((some capBenchS or some capBenchR) or no CapBenchB))) }
assert CapBenchEquivalent_cap004229 { cap004229 iff cap004229c }
check CapBenchEquivalent_cap004229 for 4

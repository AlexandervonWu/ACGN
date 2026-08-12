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

pred cap004074 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv6 and ((no CapBenchA and some CapBenchB) and some CapBenchB))) }
pred cap004074c { some a, b: CapBenchA | (b->a in capBenchR and (inv6 and ((no CapBenchA and some CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap004074 { cap004074 iff cap004074c }
check CapBenchEquivalent_cap004074 for 4

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

pred cap001069 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv6 and ((some capBenchS or some CapBenchA) or some CapBenchB))) }
pred cap001069c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv6 and ((some capBenchS or some CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap001069 { cap001069 iff cap001069c }
check CapBenchEquivalent_cap001069 for 4

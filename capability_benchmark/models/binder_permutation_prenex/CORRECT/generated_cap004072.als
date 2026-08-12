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

pred inv3 {
all u : User | u.sees - Ad in u.follows.posts
}

pred inv3c {
	all p : User | p.sees - Ad in p.follows.posts
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004072 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv3 and ((some CapBenchA and some CapBenchB) or some CapBenchB))) }
pred cap004072c { some a, b: CapBenchA | (b->a in capBenchR and (inv3 and ((some CapBenchA and some CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap004072 { cap004072 iff cap004072c }
check CapBenchEquivalent_cap004072 for 4

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
all u: User | u.sees in (u.follows.posts + Ad)
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

pred cap004093 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv3 and ((some capBenchS or no CapBenchB) or some CapBenchB))) }
pred cap004093c { some a, b: CapBenchA | (b->a in capBenchR and (inv3 and ((some capBenchS or no CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap004093 { cap004093 iff cap004093c }
check CapBenchEquivalent_cap004093 for 4

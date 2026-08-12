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

pred cap001036 { all x, y: CapBenchA | (x->y in capBenchR and (inv3 and ((some capBenchR and some capBenchR) or some CapBenchA))) }
pred cap001036c { all a, b: CapBenchA | (b->a in capBenchR and (inv3 and ((some capBenchR and some capBenchR) or some CapBenchA))) }
assert CapBenchEquivalent_cap001036 { cap001036 iff cap001036c }
check CapBenchEquivalent_cap001036 for 4

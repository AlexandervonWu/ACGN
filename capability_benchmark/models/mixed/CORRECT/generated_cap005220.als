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

pred cap005220 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((some capBenchR and no CapBenchB) or no CapBenchB)) and ((some CapBenchB or some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap005220c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv3 and ((some capBenchR and no CapBenchB) or no CapBenchB)))) }
assert CapBenchEquivalent_cap005220 { cap005220 iff cap005220c }
check CapBenchEquivalent_cap005220 for 4

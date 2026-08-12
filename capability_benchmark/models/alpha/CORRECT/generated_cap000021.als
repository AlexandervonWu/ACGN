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

pred cap000021 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv3 and ((some capBenchS or no CapBenchA) or some CapBenchA))) }
pred cap000021c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv3 and ((some capBenchS or no CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap000021 { cap000021 iff cap000021c }
check CapBenchEquivalent_cap000021 for 4

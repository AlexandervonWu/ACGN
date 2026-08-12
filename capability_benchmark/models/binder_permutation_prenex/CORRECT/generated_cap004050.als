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

pred inv8 {
all u:User,a:Ad | a in u.sees implies (some u1:User | a in u1.posts and u1 in u.follows + u.suggested)
}

pred inv8c {
	all u : User, p : u.sees & Ad | p in u.(follows+suggested).posts
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004050 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv8 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA))) }
pred cap004050c { some a, b: CapBenchA | (b->a in capBenchR and (inv8 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA))) }
assert CapBenchEquivalent_cap004050 { cap004050 iff cap004050c }
check CapBenchEquivalent_cap004050 for 4

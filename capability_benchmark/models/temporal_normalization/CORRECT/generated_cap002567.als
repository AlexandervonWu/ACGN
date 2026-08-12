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

pred cap002567 { not eventually ((inv3 and ((no CapBenchB or some CapBenchA) and some CapBenchB))) }
pred cap002567c { always (not (inv3 and ((no CapBenchB or some CapBenchA) and some CapBenchB))) }
assert CapBenchEquivalent_cap002567 { cap002567 iff cap002567c }
check CapBenchEquivalent_cap002567 for 4

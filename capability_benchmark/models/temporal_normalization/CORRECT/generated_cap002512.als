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

pred cap002512 { not always ((inv3 and ((some capBenchR and some CapBenchB) or some CapBenchA))) }
pred cap002512c { eventually (not (inv3 and ((some capBenchR and some CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap002512 { cap002512 iff cap002512c }
check CapBenchEquivalent_cap002512 for 4

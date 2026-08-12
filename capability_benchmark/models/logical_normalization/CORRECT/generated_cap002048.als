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

pred cap002048 { not not ((inv8 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) }
pred cap002048c { (inv8 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) }
assert CapBenchEquivalent_cap002048 { cap002048 iff cap002048c }
check CapBenchEquivalent_cap002048 for 4

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

pred cap002392 { ((inv8 and ((some CapBenchA and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) implies ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) }
pred cap002392c { ((not (inv8 and ((some CapBenchA and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) or ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) }
assert CapBenchEquivalent_cap002392 { cap002392 iff cap002392c }
check CapBenchEquivalent_cap002392 for 4

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

pred inv4 {
all u:User | all a:Ad | a in u.posts implies u.posts in Ad
}

pred inv4c {
	all u : posts.Ad | u.posts in Ad
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002245 { no x: CapBenchA | (x->x in capBenchR and (inv4 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB))) }
pred cap002245c { all x: CapBenchA | not (x->x in capBenchR and (inv4 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB))) }
assert CapBenchEquivalent_cap002245 { cap002245 iff cap002245c }
check CapBenchEquivalent_cap002245 for 4

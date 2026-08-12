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
all u:User | some u.posts & Ad implies u.posts in Ad
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

pred cap000736 { (inv4 and ((some capBenchR and some capBenchS) or no CapBenchB)) }
pred cap000736c { ((inv4 and ((some capBenchR and some capBenchS) or no CapBenchB)) and (inv4 and ((some capBenchR and some capBenchS) or no CapBenchB))) }
assert CapBenchEquivalent_cap000736 { cap000736 iff cap000736c }
check CapBenchEquivalent_cap000736 for 4

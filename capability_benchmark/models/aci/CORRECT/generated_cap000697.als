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
all u:User, a:Ad| u->a in posts implies u.posts in Ad
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

pred cap000697 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv4 and ((some capBenchS or some CapBenchA) or no CapBenchB))) }
pred cap000697c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv4 and ((some capBenchS or some CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap000697 { cap000697 iff cap000697c }
check CapBenchEquivalent_cap000697 for 4

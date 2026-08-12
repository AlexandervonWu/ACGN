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
all user : User |
(some user.posts & Ad) implies user.posts & Ad = user.posts
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

pred cap000773 { (inv4 and ((some CapBenchB or no CapBenchA) or some capBenchR)) }
pred cap000773c { ((inv4 and ((some CapBenchB or no CapBenchA) or some capBenchR)) or (inv4 and ((some CapBenchB or no CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap000773 { cap000773 iff cap000773c }
check CapBenchEquivalent_cap000773 for 4

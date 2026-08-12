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
all u : User, p : Photo | p in u.sees => p in u.follows.posts or p in Ad
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

pred cap002168 { not not ((inv3 and ((some CapBenchA and some capBenchS) or no CapBenchA))) }
pred cap002168c { (inv3 and ((some CapBenchA and some capBenchS) or no CapBenchA)) }
assert CapBenchEquivalent_cap002168 { cap002168 iff cap002168c }
check CapBenchEquivalent_cap002168 for 4

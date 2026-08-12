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

pred cap004556 { not ((inv3 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) and ((some capBenchS or some capBenchR) or no CapBenchB)) }
pred cap004556c { ((not ((some capBenchS or some capBenchR) or no CapBenchB)) or (not (inv3 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)))) }
assert CapBenchEquivalent_cap004556 { cap004556 iff cap004556c }
check CapBenchEquivalent_cap004556 for 4

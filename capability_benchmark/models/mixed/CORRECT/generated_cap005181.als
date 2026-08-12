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

pred cap005181 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) and ((no CapBenchA and some capBenchR) and some capBenchS))) }
pred cap005181c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and some capBenchR) and some capBenchS)) or (not (inv3 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)))) }
assert CapBenchEquivalent_cap005181 { cap005181 iff cap005181c }
check CapBenchEquivalent_cap005181 for 4

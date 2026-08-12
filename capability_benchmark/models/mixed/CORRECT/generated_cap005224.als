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
all u: User, a: Ad | a in u.sees => a in u.follows.posts or a in u.suggested.posts
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

pred cap005224 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv8 and ((some CapBenchA and some capBenchR) or no CapBenchB)) and ((some capBenchS or some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap005224c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv8 and ((some CapBenchA and some capBenchR) or no CapBenchB)))) }
assert CapBenchEquivalent_cap005224 { cap005224 iff cap005224c }
check CapBenchEquivalent_cap005224 for 4

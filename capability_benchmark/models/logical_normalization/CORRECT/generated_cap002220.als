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

pred cap002220 { not (all x: CapBenchA | (x->x in capBenchR and (inv8 and ((some capBenchR and no CapBenchB) or no CapBenchB)))) }
pred cap002220c { some x: CapBenchA | not (x->x in capBenchR and (inv8 and ((some capBenchR and no CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap002220 { cap002220 iff cap002220c }
check CapBenchEquivalent_cap002220 for 4

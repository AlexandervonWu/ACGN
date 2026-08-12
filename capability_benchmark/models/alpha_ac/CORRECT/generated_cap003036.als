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
all u: User | (u.posts in Ad) or (u.posts in Photo-Ad)
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

pred cap003036 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some capBenchR and some capBenchR) or some CapBenchA)) and ((some CapBenchB or no CapBenchA) or no CapBenchB)) }
pred cap003036c { all renamed: CapBenchA | (((some CapBenchB or no CapBenchA) or no CapBenchB) and renamed->renamed in capBenchR and (inv4 and ((some capBenchR and some capBenchR) or some CapBenchA))) }
assert CapBenchEquivalent_cap003036 { cap003036 iff cap003036c }
check CapBenchEquivalent_cap003036 for 4

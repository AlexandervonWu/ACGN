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

pred cap000591 { ((inv4 and ((no CapBenchB or no CapBenchB) and some CapBenchB)) or ((some CapBenchA and some CapBenchB) or some capBenchR) or ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap000591c { (((some CapBenchA and some CapBenchB) or some capBenchR) or ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA)) or (inv4 and ((no CapBenchB or no CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap000591 { cap000591 iff cap000591c }
check CapBenchEquivalent_cap000591 for 4

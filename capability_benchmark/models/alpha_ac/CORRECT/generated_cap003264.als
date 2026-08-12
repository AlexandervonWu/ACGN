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

pred cap003264 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some CapBenchA and some CapBenchB) or some capBenchR)) and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003264c { all renamed: CapBenchA | (((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv4 and ((some CapBenchA and some CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap003264 { cap003264 iff cap003264c }
check CapBenchEquivalent_cap003264 for 4

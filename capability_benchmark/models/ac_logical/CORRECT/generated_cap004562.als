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

pred inv5 {
all i:Influencer | follows.i = (User-i)
}

pred inv5c {
	all i : Influencer | follows.i = User - i
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004562 { not ((inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some CapBenchA)) and ((no CapBenchB or some capBenchS) and no CapBenchB)) }
pred cap004562c { ((not ((no CapBenchB or some capBenchS) and no CapBenchB)) or (not (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some CapBenchA)))) }
assert CapBenchEquivalent_cap004562 { cap004562 iff cap004562c }
check CapBenchEquivalent_cap004562 for 4

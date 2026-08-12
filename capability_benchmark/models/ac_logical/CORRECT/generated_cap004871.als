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

pred cap004871 { not ((inv5 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS)) and ((some CapBenchA and some capBenchR) or some CapBenchA)) }
pred cap004871c { ((not ((some CapBenchA and some capBenchR) or some CapBenchA)) or (not (inv5 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS)))) }
assert CapBenchEquivalent_cap004871 { cap004871 iff cap004871c }
check CapBenchEquivalent_cap004871 for 4

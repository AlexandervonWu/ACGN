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

pred cap000824 { ((inv5 and ((some capBenchR and some CapBenchA) or some capBenchS)) and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchA)) }
pred cap000824c { (((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchA) and (inv5 and ((some capBenchR and some CapBenchA) or some capBenchS)) and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB)) }
assert CapBenchEquivalent_cap000824 { cap000824 iff cap000824c }
check CapBenchEquivalent_cap000824 for 4

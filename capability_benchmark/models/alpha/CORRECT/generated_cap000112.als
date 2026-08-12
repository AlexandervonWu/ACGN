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

pred inv7 {
all u : User | u.follows.follows - u - u.follows = u.suggested
}

pred inv7c {
	all u : User | u.suggested = u.follows.follows - u.follows - u
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000112 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv7 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB))) }
pred cap000112c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv7 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB))) }
assert CapBenchEquivalent_cap000112 { cap000112 iff cap000112c }
check CapBenchEquivalent_cap000112 for 4

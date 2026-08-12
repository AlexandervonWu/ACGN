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

pred cap000148 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv7 and ((some capBenchR and no CapBenchA) or no CapBenchA))) }
pred cap000148c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv7 and ((some capBenchR and no CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap000148 { cap000148 iff cap000148c }
check CapBenchEquivalent_cap000148 for 4

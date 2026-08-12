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
all u, s: User | s in u.suggested iff s not in u.follows and s in u.follows.follows and s != u
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

pred cap000749 { (inv7 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)) }
pred cap000749c { ((inv7 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)) or (inv7 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap000749 { cap000749 iff cap000749c }
check CapBenchEquivalent_cap000749 for 4

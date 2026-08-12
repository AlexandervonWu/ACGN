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

pred cap003270 { all x: CapBenchA | (x->x in capBenchR and (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchR)) and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003270c { all renamed: CapBenchA | (((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap003270 { cap003270 iff cap003270c }
check CapBenchEquivalent_cap003270 for 4

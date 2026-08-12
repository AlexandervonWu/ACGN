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

pred cap004262 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchR))) }
pred cap004262c { some a, b: CapBenchA | (b->a in capBenchR and (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap004262 { cap004262 iff cap004262c }
check CapBenchEquivalent_cap004262 for 4

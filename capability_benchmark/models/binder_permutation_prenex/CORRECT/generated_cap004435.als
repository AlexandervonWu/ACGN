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

pred cap004435 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv5 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap004435c { some a, b: CapBenchA | (b->a in capBenchR and (inv5 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap004435 { cap004435 iff cap004435c }
check CapBenchEquivalent_cap004435 for 4

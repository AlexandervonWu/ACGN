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

pred cap005297 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv5 and ((some CapBenchB or some capBenchS) or some capBenchR)) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap005297c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv5 and ((some CapBenchB or some capBenchS) or some capBenchR)))) }
assert CapBenchEquivalent_cap005297 { cap005297 iff cap005297c }
check CapBenchEquivalent_cap005297 for 4

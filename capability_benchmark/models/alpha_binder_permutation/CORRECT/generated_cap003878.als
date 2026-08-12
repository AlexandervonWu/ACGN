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

pred cap003878 { all x, y: CapBenchA | (x->y in capBenchR and (inv5 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchS))) }
pred cap003878c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv5 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap003878 { cap003878 iff cap003878c }
check CapBenchEquivalent_cap003878 for 4

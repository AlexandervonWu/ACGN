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

pred cap001661 { ((all x: CapBenchA | x->x in capBenchR) or (inv5 and ((some CapBenchB or some capBenchR) or no CapBenchA))) }
pred cap001661c { (all x: CapBenchA | (x->x in capBenchR or (inv5 and ((some CapBenchB or some capBenchR) or no CapBenchA)))) }
assert CapBenchEquivalent_cap001661 { cap001661 iff cap001661c }
check CapBenchEquivalent_cap001661 for 4

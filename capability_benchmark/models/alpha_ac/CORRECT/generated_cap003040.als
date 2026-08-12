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

pred cap003040 { all x: CapBenchA | (x->x in capBenchR and (inv5 and ((some CapBenchA and some capBenchS) or some CapBenchA)) and ((some capBenchS or no CapBenchA) or no CapBenchB)) }
pred cap003040c { all renamed: CapBenchA | (((some capBenchS or no CapBenchA) or no CapBenchB) and renamed->renamed in capBenchR and (inv5 and ((some CapBenchA and some capBenchS) or some CapBenchA))) }
assert CapBenchEquivalent_cap003040 { cap003040 iff cap003040c }
check CapBenchEquivalent_cap003040 for 4

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

pred cap002039 { ((inv5 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchA)) iff ((some capBenchR and no CapBenchA) or no CapBenchB)) }
pred cap002039c { (((not (inv5 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchA))) or ((some capBenchR and no CapBenchA) or no CapBenchB)) and ((not ((some capBenchR and no CapBenchA) or no CapBenchB)) or (inv5 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchA)))) }
assert CapBenchEquivalent_cap002039 { cap002039 iff cap002039c }
check CapBenchEquivalent_cap002039 for 4

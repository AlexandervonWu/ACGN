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

pred inv2 {
all u: User | u -> u not in follows
all u: User | u not in u.follows
follows - iden = follows
}

pred inv2c {
	all p : User | p not in p.follows
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000048 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv2 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) }
pred cap000048c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv2 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) }
assert CapBenchEquivalent_cap000048 { cap000048 iff cap000048c }
check CapBenchEquivalent_cap000048 for 4

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

pred inv3 {
all p: Photo - Ad, u1: User | some u2: User | u1->p in sees => u2->p in posts and u1->u2 in follows
}

pred inv3c {
	all p : User | p.sees - Ad in p.follows.posts
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000364 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv3 and ((some capBenchR and some capBenchS) or some capBenchS))) }
pred cap000364c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv3 and ((some capBenchR and some capBenchS) or some capBenchS))) }
assert CapBenchEquivalent_cap000364 { cap000364 iff cap000364c }
check CapBenchEquivalent_cap000364 for 4

open util/ordering[Grade]

sig Person {
	teaches : set Course,
	enrolled : set Course,
	projects : set Project
}

sig Professor,Student in Person {}

sig Course {
	projects : set Project,
	grades : Person -> Grade
}

sig Project {}

sig Grade {}

pred inv8 {
all p:Person,c:Course | c in p.teaches implies c not in p.enrolled
}

pred inv8c {
	(all p : Person | no p.teaches & p.enrolled)
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002262 { not (all x: CapBenchA | (x->x in capBenchR and (inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchR)))) }
pred cap002262c { some x: CapBenchA | not (x->x in capBenchR and (inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap002262 { cap002262 iff cap002262c }
check CapBenchEquivalent_cap002262 for 4

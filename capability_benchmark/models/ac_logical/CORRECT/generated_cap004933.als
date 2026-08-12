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

pred inv1 {
all x: Person - Student | no x.enrolled
}

pred inv1c {
	enrolled in Student -> Course
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004933 { not ((inv1 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA))) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchB)) }
pred cap004933c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchB)) or (not (inv1 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004933 { cap004933 iff cap004933c }
check CapBenchEquivalent_cap004933 for 4

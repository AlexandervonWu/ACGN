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

pred inv3 {
all c : Course | some teaches.c
}

pred inv3c {
	teaches in Person some -> Course
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004564 { not ((inv3 and ((some CapBenchA and some CapBenchA) or some CapBenchB)) and ((some capBenchS or some capBenchS) or no CapBenchB)) }
pred cap004564c { ((not ((some capBenchS or some capBenchS) or no CapBenchB)) or (not (inv3 and ((some CapBenchA and some CapBenchA) or some CapBenchB)))) }
assert CapBenchEquivalent_cap004564 { cap004564 iff cap004564c }
check CapBenchEquivalent_cap004564 for 4

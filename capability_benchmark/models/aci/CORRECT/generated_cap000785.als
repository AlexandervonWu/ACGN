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

pred cap000785 { (inv3 and ((some capBenchS or no CapBenchB) or some capBenchR)) }
pred cap000785c { ((inv3 and ((some capBenchS or no CapBenchB) or some capBenchR)) or (inv3 and ((some capBenchS or no CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap000785 { cap000785 iff cap000785c }
check CapBenchEquivalent_cap000785 for 4

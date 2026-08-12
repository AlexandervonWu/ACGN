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

pred inv2 {
teaches.Course in Professor
}

pred inv2c {
	teaches in Professor -> Course
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000778 { (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchR)) }
pred cap000778c { ((inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchR)) and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap000778 { cap000778 iff cap000778c }
check CapBenchEquivalent_cap000778 for 4

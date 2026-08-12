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

pred cap002264 { not not ((inv2 and ((some CapBenchA and some CapBenchB) or some capBenchR))) }
pred cap002264c { (inv2 and ((some CapBenchA and some CapBenchB) or some capBenchR)) }
assert CapBenchEquivalent_cap002264 { cap002264 iff cap002264c }
check CapBenchEquivalent_cap002264 for 4

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
all p:Person, c:Course | p in teaches.c implies p in Professor
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

pred cap002140 { ((inv2 and ((some capBenchR and some CapBenchB) or no CapBenchA)) implies ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchR)) }
pred cap002140c { ((not (inv2 and ((some capBenchR and some CapBenchB) or no CapBenchA))) or ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchR)) }
assert CapBenchEquivalent_cap002140 { cap002140 iff cap002140c }
check CapBenchEquivalent_cap002140 for 4

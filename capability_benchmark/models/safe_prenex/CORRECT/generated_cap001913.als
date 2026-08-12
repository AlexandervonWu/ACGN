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

pred cap001913 { ((all x: CapBenchA | x->x in capBenchR) or (inv2 and ((some capBenchS or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap001913c { (all x: CapBenchA | (x->x in capBenchR or (inv2 and ((some capBenchS or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap001913 { cap001913 iff cap001913c }
check CapBenchEquivalent_cap001913 for 4

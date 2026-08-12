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

pred cap003405 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some capBenchS or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchA and some CapBenchA) and some CapBenchB)) }
pred cap003405c { all renamed: CapBenchA | (((no CapBenchA and some CapBenchA) and some CapBenchB) and renamed->renamed in capBenchR and (inv2 and ((some capBenchS or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003405 { cap003405 iff cap003405c }
check CapBenchEquivalent_cap003405 for 4

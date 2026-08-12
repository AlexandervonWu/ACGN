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

pred cap003093 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some capBenchS or no CapBenchB) or some CapBenchB)) and ((no CapBenchA and some CapBenchB) and some capBenchR)) }
pred cap003093c { all renamed: CapBenchA | (((no CapBenchA and some CapBenchB) and some capBenchR) and renamed->renamed in capBenchR and (inv2 and ((some capBenchS or no CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap003093 { cap003093 iff cap003093c }
check CapBenchEquivalent_cap003093 for 4

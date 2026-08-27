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

pred cap000930 { (some (((CapBenchA + CapBenchB) & CapBenchA) & CapBenchA) and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap000930c { (some ((CapBenchA + CapBenchB) & (CapBenchA & CapBenchA)) and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000930 { cap000930 iff cap000930c }
check CapBenchEquivalent_cap000930 for 4

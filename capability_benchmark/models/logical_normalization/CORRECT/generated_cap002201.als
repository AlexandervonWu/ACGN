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

pred cap002201 { ((inv2 and ((some CapBenchB or some CapBenchB) or no CapBenchB)) iff ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS)) }
pred cap002201c { (((not (inv2 and ((some CapBenchB or some CapBenchB) or no CapBenchB))) or ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS)) and ((not ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS)) or (inv2 and ((some CapBenchB or some CapBenchB) or no CapBenchB)))) }
assert CapBenchEquivalent_cap002201 { cap002201 iff cap002201c }
check CapBenchEquivalent_cap002201 for 4

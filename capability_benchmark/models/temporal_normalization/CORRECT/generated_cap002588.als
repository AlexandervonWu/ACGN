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
all x: Person - Professor | no x.teaches
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

pred cap002588 { not (((inv2 and ((some CapBenchA and no CapBenchB) or some CapBenchB))) until (((some capBenchS or some CapBenchA) or some capBenchR))) }
pred cap002588c { ((not (inv2 and ((some CapBenchA and no CapBenchB) or some CapBenchB))) releases (not ((some capBenchS or some CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap002588 { cap002588 iff cap002588c }
check CapBenchEquivalent_cap002588 for 4

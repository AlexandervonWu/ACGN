sig Workstation {
	workers : set Worker,
	succ : set Workstation
}
one sig begin, end in Workstation {}

sig Worker {}
sig Human, Robot extends Worker {}

abstract sig Product {
	parts : set Product	
}

sig Material extends Product {}

sig Component extends Product {
	workstation : set Workstation
}

sig Dangerous in Product {}
pred inv2 {
all wtt : Workstation | some wtt.workers
all w : Worker | one wtt : Workstation | w in wtt.workers
}

pred inv2c {
	workers in Workstation one -> some Worker
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004839 { not ((inv2 and ((no CapBenchB or no CapBenchA) and some capBenchS)) and ((some CapBenchA and some CapBenchA) or some CapBenchA)) }
pred cap004839c { ((not ((some CapBenchA and some CapBenchA) or some CapBenchA)) or (not (inv2 and ((no CapBenchB or no CapBenchA) and some capBenchS)))) }
assert CapBenchEquivalent_cap004839 { cap004839 iff cap004839c }
check CapBenchEquivalent_cap004839 for 4

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

pred cap000696 { (some (((CapBenchA + CapBenchB) & CapBenchA) & CapBenchA) and (inv2 and ((some capBenchR and some CapBenchA) or no CapBenchB))) }
pred cap000696c { (some ((CapBenchA + CapBenchB) & (CapBenchA & CapBenchA)) and (inv2 and ((some capBenchR and some CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap000696 { cap000696 iff cap000696c }
check CapBenchEquivalent_cap000696 for 4

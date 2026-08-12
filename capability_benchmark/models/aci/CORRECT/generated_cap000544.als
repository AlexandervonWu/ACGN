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
pred inv1 {
all w:Worker | w in Human or w in Robot
}

pred inv1c {
	Worker = Human + Robot	
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000544 { (inv1 and ((some capBenchR and some capBenchS) or some CapBenchA)) }
pred cap000544c { ((inv1 and ((some capBenchR and some capBenchS) or some CapBenchA)) and (inv1 and ((some capBenchR and some capBenchS) or some CapBenchA))) }
assert CapBenchEquivalent_cap000544 { cap000544 iff cap000544c }
check CapBenchEquivalent_cap000544 for 4

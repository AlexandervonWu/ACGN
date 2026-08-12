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
all w : Worker | w in Human + Robot
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

pred cap000916 { (inv1 and ((some CapBenchA and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap000916c { ((inv1 and ((some CapBenchA and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))) and (inv1 and ((some CapBenchA and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000916 { cap000916 iff cap000916c }
check CapBenchEquivalent_cap000916 for 4

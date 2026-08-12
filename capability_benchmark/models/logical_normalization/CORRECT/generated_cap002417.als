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

pred cap002417 { ((inv1 and ((some CapBenchB or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))) iff ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchB)) }
pred cap002417c { (((not (inv1 and ((some CapBenchB or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA)))) or ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchB)) and ((not ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchB)) or (inv1 and ((some CapBenchB or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap002417 { cap002417 iff cap002417c }
check CapBenchEquivalent_cap002417 for 4

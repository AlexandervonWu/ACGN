sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv1 {
some t,a:Track| t in Entry and a in Exit
}

pred inv1c {
	some Entry
	some Exit
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000650 { ((inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchA)) and ((no CapBenchB or some CapBenchA) and some capBenchS) and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap000650c { (((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB) and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchA)) and ((no CapBenchB or some CapBenchA) and some capBenchS)) }
assert CapBenchEquivalent_cap000650 { cap000650 iff cap000650c }
check CapBenchEquivalent_cap000650 for 4

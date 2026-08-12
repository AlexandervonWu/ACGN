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

pred cap002183 { ((inv1 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)) iff ((some capBenchR and some capBenchR) or some capBenchS)) }
pred cap002183c { (((not (inv1 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA))) or ((some capBenchR and some capBenchR) or some capBenchS)) and ((not ((some capBenchR and some capBenchR) or some capBenchS)) or (inv1 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)))) }
assert CapBenchEquivalent_cap002183 { cap002183 iff cap002183c }
check CapBenchEquivalent_cap002183 for 4

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

pred cap002057 { ((inv1 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) iff ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchB)) }
pred cap002057c { (((not (inv1 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA))) or ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchB)) and ((not ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchB)) or (inv1 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)))) }
assert CapBenchEquivalent_cap002057 { cap002057 iff cap002057c }
check CapBenchEquivalent_cap002057 for 4

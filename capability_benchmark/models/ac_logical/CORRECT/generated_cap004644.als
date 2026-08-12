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

pred cap004644 { not ((inv1 and ((some CapBenchA and no CapBenchA) or no CapBenchA)) and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchR)) }
pred cap004644c { ((not ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchR)) or (not (inv1 and ((some CapBenchA and no CapBenchA) or no CapBenchA)))) }
assert CapBenchEquivalent_cap004644 { cap004644 iff cap004644c }
check CapBenchEquivalent_cap004644 for 4

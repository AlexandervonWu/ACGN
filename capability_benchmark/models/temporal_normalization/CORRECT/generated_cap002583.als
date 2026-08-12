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

pred cap002583 { not (((inv1 and ((no CapBenchB or no CapBenchA) and some CapBenchB))) since (((some CapBenchA and some CapBenchA) or some capBenchR))) }
pred cap002583c { ((not (inv1 and ((no CapBenchB or no CapBenchA) and some CapBenchB))) triggered (not ((some CapBenchA and some CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap002583 { cap002583 iff cap002583c }
check CapBenchEquivalent_cap002583 for 4

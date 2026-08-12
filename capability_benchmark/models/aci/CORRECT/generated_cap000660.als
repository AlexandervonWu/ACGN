sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv2 {
all s : Signal | one signals.s
}

pred inv2c {
	all s : Signal | one signals.s
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000660 { (some ((CapBenchA.capBenchR).capBenchR) and (inv2 and ((some CapBenchA and some capBenchR) or no CapBenchA))) }
pred cap000660c { (some (CapBenchA.(capBenchR.capBenchR)) and (inv2 and ((some CapBenchA and some capBenchR) or no CapBenchA))) }
assert CapBenchEquivalent_cap000660 { cap000660 iff cap000660c }
check CapBenchEquivalent_cap000660 for 4

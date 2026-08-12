sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv2 {
all x: Signal | one y : Track | x in y.signals
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

pred cap000856 { (inv2 and ((some capBenchR and some capBenchR) or some capBenchS)) }
pred cap000856c { ((inv2 and ((some capBenchR and some capBenchR) or some capBenchS)) and (inv2 and ((some capBenchR and some capBenchR) or some capBenchS))) }
assert CapBenchEquivalent_cap000856 { cap000856 iff cap000856c }
check CapBenchEquivalent_cap000856 for 4

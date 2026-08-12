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

pred cap002200 { ((inv2 and ((some CapBenchA and some CapBenchB) or no CapBenchB)) implies ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) }
pred cap002200c { ((not (inv2 and ((some CapBenchA and some CapBenchB) or no CapBenchB))) or ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) }
assert CapBenchEquivalent_cap002200 { cap002200 iff cap002200c }
check CapBenchEquivalent_cap002200 for 4

sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv4 {
all t : Track | t in Entry iff no t.~succs
}

pred inv4c {
	all t : Track | t in Entry iff no succs.t
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002116 { ((inv4 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)) implies ((some CapBenchB or some capBenchR) or some capBenchR)) }
pred cap002116c { ((not (inv4 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB))) or ((some CapBenchB or some capBenchR) or some capBenchR)) }
assert CapBenchEquivalent_cap002116 { cap002116 iff cap002116c }
check CapBenchEquivalent_cap002116 for 4

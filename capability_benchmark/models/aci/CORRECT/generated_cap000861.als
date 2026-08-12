sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv7 {
all t:Track | no t & t.(^succs)
}

pred inv7c {
	no t : Track | t in t.^succs
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000861 { ((inv7 and ((some CapBenchB or some capBenchS) or some capBenchS)) or ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchA) or ((some capBenchR and some CapBenchA) or no CapBenchB)) }
pred cap000861c { (((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchA) or ((some capBenchR and some CapBenchA) or no CapBenchB) or (inv7 and ((some CapBenchB or some capBenchS) or some capBenchS))) }
assert CapBenchEquivalent_cap000861 { cap000861 iff cap000861c }
check CapBenchEquivalent_cap000861 for 4

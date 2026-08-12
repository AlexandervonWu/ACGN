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

pred cap000664 { (inv7 and ((some capBenchR and some capBenchR) or no CapBenchA)) }
pred cap000664c { ((inv7 and ((some capBenchR and some capBenchR) or no CapBenchA)) and (inv7 and ((some capBenchR and some capBenchR) or no CapBenchA))) }
assert CapBenchEquivalent_cap000664 { cap000664 iff cap000664c }
check CapBenchEquivalent_cap000664 for 4

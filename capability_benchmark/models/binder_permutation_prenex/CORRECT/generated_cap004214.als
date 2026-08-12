sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv9 {
all t: Track | no Junction & t.succs => no Semaphore & t.signals
}

pred inv9c {
	all t : Track | no t.succs & Junction implies no t.signals & Semaphore
}

check correct { inv9 <=> inv9c}
pred under { inv9 and !inv9c}
pred over { !inv9 and inv9c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004214 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv9 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchB))) }
pred cap004214c { some a, b: CapBenchA | (b->a in capBenchR and (inv9 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchB))) }
assert CapBenchEquivalent_cap004214 { cap004214 iff cap004214c }
check CapBenchEquivalent_cap004214 for 4

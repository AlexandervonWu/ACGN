sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv9 {
all t : Track | (no t.succs & Junction) implies no (t.signals & Semaphore)
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

pred cap000753 { ((inv9 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)) or ((no CapBenchA and some capBenchS) and capBenchR in (CapBenchA -> CapBenchA)) or ((some CapBenchA and no CapBenchB) or some CapBenchB)) }
pred cap000753c { (((no CapBenchA and some capBenchS) and capBenchR in (CapBenchA -> CapBenchA)) or ((some CapBenchA and no CapBenchB) or some CapBenchB) or (inv9 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap000753 { cap000753 iff cap000753c }
check CapBenchEquivalent_cap000753 for 4

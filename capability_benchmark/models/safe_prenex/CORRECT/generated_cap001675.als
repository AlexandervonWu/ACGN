sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv6 {
all e : Event | some (trans.State).e
}

pred inv6c {
	State.trans.State = Event
}

check correct { inv6 <=> inv6c}
pred under { inv6 and !inv6c}
pred over { !inv6 and inv6c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001675 { ((all x: CapBenchA | x->x in capBenchR) or (inv6 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchA))) }
pred cap001675c { (all x: CapBenchA | (x->x in capBenchR or (inv6 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchA)))) }
assert CapBenchEquivalent_cap001675 { cap001675 iff cap001675c }
check CapBenchEquivalent_cap001675 for 4

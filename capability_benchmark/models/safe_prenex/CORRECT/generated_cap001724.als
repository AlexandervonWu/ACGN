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

pred cap001724 { ((some x: CapBenchA | x->x in capBenchR) and (inv6 and ((some CapBenchA and some capBenchR) or no CapBenchB))) }
pred cap001724c { (some x: CapBenchA | (x->x in capBenchR and (inv6 and ((some CapBenchA and some capBenchR) or no CapBenchB)))) }
assert CapBenchEquivalent_cap001724 { cap001724 iff cap001724c }
check CapBenchEquivalent_cap001724 for 4

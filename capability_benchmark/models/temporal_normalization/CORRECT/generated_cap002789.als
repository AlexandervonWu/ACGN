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

pred cap002789 { not eventually ((inv6 and ((some CapBenchB or some capBenchR) or some capBenchR))) }
pred cap002789c { always (not (inv6 and ((some CapBenchB or some capBenchR) or some capBenchR))) }
assert CapBenchEquivalent_cap002789 { cap002789 iff cap002789c }
check CapBenchEquivalent_cap002789 for 4

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

pred cap002849 { not eventually ((inv6 and ((some capBenchS or no CapBenchB) or some capBenchS))) }
pred cap002849c { always (not (inv6 and ((some capBenchS or no CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap002849 { cap002849 iff cap002849c }
check CapBenchEquivalent_cap002849 for 4

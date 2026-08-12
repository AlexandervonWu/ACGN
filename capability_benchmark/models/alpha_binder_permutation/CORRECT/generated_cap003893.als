sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv6 {
all e:Event | some s1,s2:State | s1->e->s2 in trans
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

pred cap003893 { all x, y: CapBenchA | (x->y in capBenchR and (inv6 and ((some CapBenchB or some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap003893c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv6 and ((some CapBenchB or some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003893 { cap003893 iff cap003893c }
check CapBenchEquivalent_cap003893 for 4

sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv3 {
all s,s1,s2:State,e:Event | s->e->s1 in trans and s->e->s2 in trans implies s1=s2
}

pred inv3c {
	all s : State, e : Event | lone e.(s.trans)
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003742 { all x, y: CapBenchA | (x->y in capBenchR and (inv3 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB))) }
pred cap003742c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv3 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB))) }
assert CapBenchEquivalent_cap003742 { cap003742 iff cap003742c }
check CapBenchEquivalent_cap003742 for 4

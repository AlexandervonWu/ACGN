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

pred cap005389 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((some capBenchS or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA))) }
pred cap005389c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)) or (not (inv3 and ((some capBenchS or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap005389 { cap005389 iff cap005389c }
check CapBenchEquivalent_cap005389 for 4

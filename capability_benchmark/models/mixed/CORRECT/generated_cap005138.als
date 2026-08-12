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

pred cap005138 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((no CapBenchA and some CapBenchB) and no CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR))) }
pred cap005138c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR)) or (not (inv3 and ((no CapBenchA and some CapBenchB) and no CapBenchA)))) }
assert CapBenchEquivalent_cap005138 { cap005138 iff cap005138c }
check CapBenchEquivalent_cap005138 for 4

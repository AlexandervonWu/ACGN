sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv5 {
all f : File - Protected | f in Trash
}

pred inv5c {
  	File = Trash + Protected
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005097 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv5 and ((some CapBenchB or some capBenchR) or some CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchR))) }
pred cap005097c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchR)) or (not (inv5 and ((some CapBenchB or some capBenchR) or some CapBenchB)))) }
assert CapBenchEquivalent_cap005097 { cap005097 iff cap005097c }
check CapBenchEquivalent_cap005097 for 4

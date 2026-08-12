sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv7 {
no link.Trash
}

pred inv7c {
	no File.link & Trash
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003097 { all x: CapBenchA | (x->x in capBenchR and (inv7 and ((some CapBenchB or some capBenchR) or some CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchR)) }
pred cap003097c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchR) and renamed->renamed in capBenchR and (inv7 and ((some CapBenchB or some capBenchR) or some CapBenchB))) }
assert CapBenchEquivalent_cap003097 { cap003097 iff cap003097c }
check CapBenchEquivalent_cap003097 for 4

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

pred cap002005 { no x: CapBenchA | (x->x in capBenchR and (inv7 and ((some capBenchS or some CapBenchA) or some CapBenchA))) }
pred cap002005c { all x: CapBenchA | not (x->x in capBenchR and (inv7 and ((some capBenchS or some CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap002005 { cap002005 iff cap002005c }
check CapBenchEquivalent_cap002005 for 4

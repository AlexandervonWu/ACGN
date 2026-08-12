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

pred cap001921 { ((all x: CapBenchA | x->x in capBenchR) or (inv7 and ((some capBenchS or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap001921c { (all x: CapBenchA | (x->x in capBenchR or (inv7 and ((some capBenchS or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap001921 { cap001921 iff cap001921c }
check CapBenchEquivalent_cap001921 for 4

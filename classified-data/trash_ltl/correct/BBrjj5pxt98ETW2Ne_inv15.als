var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv15 {
always(all f : (File - Trash) | eventually f in Trash)
}

pred inv15c {
	always (all f:File | eventually f in Trash)
}

check correct { inv15 <=> inv15c}
pred under { inv15 and !inv15c}
pred over { !inv15 and inv15c}
run over 
run under 



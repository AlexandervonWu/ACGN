var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv5 {
some f:File | eventually f in Trash and f.~link in Trash
}

pred inv5c {
	eventually (some f:File | f not in File')
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



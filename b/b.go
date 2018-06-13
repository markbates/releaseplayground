package b

import "github.com/gobuffalo/packr"

var box = packr.NewBox("./templates")

func B() string {
	return box.String("b.txt")
}

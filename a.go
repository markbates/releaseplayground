package releaseplayground

import "github.com/gobuffalo/packr"

var box = packr.NewBox("./templates")

func A() string {
	return box.String("a.txt")
}

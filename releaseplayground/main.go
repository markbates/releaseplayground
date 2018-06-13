package main

import (
	"fmt"

	"github.com/markbates/releaseplayground"
	"github.com/markbates/releaseplayground/b"
	"github.com/markbates/releaseplayground/runtime"
)

func main() {
	fmt.Println(runtime.Version)
	fmt.Print(releaseplayground.A())
	fmt.Print(b.B())
}

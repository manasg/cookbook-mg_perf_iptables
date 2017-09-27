package main

// example go server from https://golang.org/doc/articles/wiki/#tmp_3
// with some cmd line args and access logs

import (
	"fmt"
	"github.com/gorilla/handlers"
	"net/http"
	"os"
	"strconv"
	"time"
)

func echoHandler(w http.ResponseWriter, r *http.Request) {
	params := r.URL.Query()
	s, ok := params["sleep_ms"]
	if ok {
		d, err := strconv.Atoi(s[0])
		if err == nil {
			time.Sleep(time.Millisecond * time.Duration(d))
		}
	}

	fmt.Fprintf(w, "echo back: %s", r.URL.Path[1:])
}

func main() {
	listen := "127.0.0.1:8080"
	if len(os.Args) >= 2 {
		listen = os.Args[1]
	}

	fmt.Println("Listening on", listen)

	http.HandleFunc("/", echoHandler)
	loggedRouter := handlers.LoggingHandler(os.Stdout, http.DefaultServeMux)
	http.ListenAndServe(listen, loggedRouter)

	fmt.Println("Terminated")
}

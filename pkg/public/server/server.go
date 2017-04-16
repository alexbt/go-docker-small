package server

import (
	"net/http"
	"fmt"
	"log"
	"github.com/gorilla/mux"
	"io"
)

var contextRoot = "/tinyimage"

func StartServer() {
	println("1...")
	router := mux.NewRouter()
	println("2...")
	router.HandleFunc(contextRoot, HandleRequests).Methods(http.MethodGet)
	println("3...")
	httpServer := http.ListenAndServe(fmt.Sprintf(":%s", "8080"), router)
	println("Listening...")
	log.Fatal(httpServer)
}

func HandleRequests(writer http.ResponseWriter, reader *http.Request) {
	println("handleRequest...")
	io.WriteString(writer, "Hello World")
}

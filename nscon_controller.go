package main

import (
	"fmt"
	"github.com/mzyy94/nscon"
	"log"
	"net/http"
	"os"
	"os/signal"
	"time"
)

// setInput関数はボタンを押して100ms後に離す
func setInput(input *uint8) {
	*input++
	time.AfterFunc(100*time.Millisecond, func() {
		*input--
	})
}

func main() {
	target := "/dev/hidg0"
	con := nscon.NewController(target)
	con.LogLevel = 1
	defer con.Close()
	con.Connect()

	// コマンドマッピング
	commandMap := map[string]func(){
		"a":     func() { setInput(&con.Input.Dpad.Left) },
		"d":     func() { setInput(&con.Input.Dpad.Right) },
		"w":     func() { setInput(&con.Input.Dpad.Up) },
		"s":     func() { setInput(&con.Input.Dpad.Down) },
		"space": func() { setInput(&con.Input.Button.B) },
		"enter": func() { setInput(&con.Input.Button.A) },
		"x":     func() { setInput(&con.Input.Button.X) },
		"y":     func() { setInput(&con.Input.Button.Y) },
		"esc":   func() { setInput(&con.Input.Button.Home) },
		"cap":   func() { setInput(&con.Input.Button.Capture) },
		"tab":   func() { setInput(&con.Input.Button.ZL) },
		"q":     func() { setInput(&con.Input.Button.L) },
		"r":     func() { setInput(&con.Input.Button.R) },
		"zr":    func() { setInput(&con.Input.Button.ZR) },
		"plus":  func() { setInput(&con.Input.Button.Plus) },
		"minus": func() { setInput(&con.Input.Button.Minus) },
	}

	// ハンドラ登録
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		// ログ出力
		log.Printf("Request: %s %s from %s\n", r.Method, r.URL.Path, r.RemoteAddr)

		// CORS対応（必要に応じて）
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type")

		// OPTIONSメソッドのプリフライトに対応
		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusOK)
			return
		}

		key := r.URL.Path[1:] // "/a" → "a"
		if handler, ok := commandMap[key]; ok {
			handler()
			fmt.Fprintf(w, "Executed %s\n", key)
			log.Printf("Executed command: %s\n", key)
		} else {
			http.Error(w, "Unknown command: "+r.URL.Path, http.StatusNotFound)
			log.Printf("Unknown command: %s\n", key)
				log.Println("kfdajkfafpdska")
		}
	})

	// サーバ起動
	go func() {
		log.Println("Starting server on http://localhost:8080")
		if err := http.ListenAndServe(":8080", nil); err != nil {
			log.Fatal(err)
		}
	}()

	// Ctrl+Cで終了待機
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt)
	<-c
	log.Println("Shutting down")
}

package main

/*
#cgo CFLAGS: -I/usr/local/include
#cgo LDFLAGS: -L/usr/local/lib -lwiringPi

#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <wiringPiSPI.h>
#include <mcp3002.h>
*/
import "C"
import (
	"env"
	"time"
	"os/exec"
	"fmt"
	"os"
)

const (
	spi_ch            = 0
	pin_base          = 100
	pin_network_delay = pin_base
	pin_packet_lost   = pin_base + 1
)

type spi_input struct {
	delay int
	lost  int
}

func exec_cmd(cmd string) (ret *exec.Cmd) {
	if len(cmd) > 0 {
		ret = exec.Command(os.Getenv("SHELL"), "-c", cmd)
	}
	return
}

func main() {
	msg := "    ____        __        ____       __    _ __ __\n"
	msg += "   / __ \\____ _/ /_____  / __ \\_____/ /_  (_) //_/_  ______\n"
	msg += "  / /_/ / __ `/ //_/ _ \\/ / / / ___/ __ \\/ / ,< / / / / __ \\\n"
	msg += " / ____/ /_/ / ,< /  __/ /_/ / /__/ / / / / /| / /_/ / / / /\n"
	msg += "/_/    \\__,_/_/|_|\\___/\\____/\\___/_/ /_/_/_/ |_\\__,_/_/ /_/\n"
	println(msg)

	var sudo string
	run_user, _ := exec_cmd("whoami | tr -d \"\n\"").Output()
	if string(run_user) == "root" {
		sudo = "sudo "
	}

	// initialise mcp3002
	if int(C.mcp3002Setup(C.int(pin_base), C.int(spi_ch))) > 0 {
		// success
		devices := []string{
			"eth0",
			"wlan0",
		}
		var device string
		var tc_del, tc_add *exec.Cmd
		for _, device := range devices {
			tc_del = exec_cmd(fmt.Sprintf(sudo + "tc qdisc del dev %s root >/dev/null 2>&1", device))
			tc_add = exec_cmd(fmt.Sprintf(sudo + "tc qdisc add dev %s root netem delay 0ms loss 0%%", device))
			tc_del.Start()
			tc_del.Wait()
			tc_add.Start()
			tc_add.Wait()
		}

		var si_new, si_old spi_input
		var tc_change *exec.Cmd
		for {
			si_old = si_new
			si_new = spi_input{
				delay: int((int(C.analogRead(C.int(pin_network_delay)))+1)/2),
				lost:  int((float32(int(C.analogRead(C.int(pin_packet_lost)))+1) / float32(1024)) * float32(100)),
			}
			if si_old.delay != si_new.delay || si_old.lost != si_new.lost {
				if env.DEBUG {
					println("SPI (ch0) input has changed.")
					println("delay :", si_old.delay, "->", si_new.delay)
					println("lost  :", si_old.lost, "->", si_new.lost)
					println("----------")
				}
				for _, device = range devices {
					tc_change = exec_cmd(fmt.Sprintf(
							sudo + "tc qdisc change dev %s root netem delay %dms loss %d%%",
							device,
							si_new.delay,
							si_new.lost))
					tc_change.Start()
					tc_change.Wait()
				}
			}
			time.Sleep(time.Millisecond * time.Duration(100))
		}
	}
}

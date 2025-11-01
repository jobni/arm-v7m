transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+umult  -L xil_defaultlib -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.umult xil_defaultlib.glbl

do {umult.udo}

run 1000ns

endsim

quit -force

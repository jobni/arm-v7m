transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+udiv  -L xil_defaultlib -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.udiv xil_defaultlib.glbl

do {udiv.udo}

run 1000ns

endsim

quit -force

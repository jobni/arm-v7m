transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+sdiv  -L xil_defaultlib -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.sdiv xil_defaultlib.glbl

do {sdiv.udo}

run 1000ns

endsim

quit -force

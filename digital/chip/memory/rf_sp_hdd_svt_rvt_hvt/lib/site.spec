# generic switches
instname=rf_sp_hdd_svt_rvt_hvt
words=32
bits=32
frequency=1
#ring_width=2
ring_width_core=2
ring_width_periphery=2
mux=1
drive=4
top_layer=m5-m9
write_mask=off
wp_size=8
power_type=otc
horiz=met3
vert=met2
bmux=off
pin_space=0.0
redundancy=off
rrows=0
rcols=1
ema=on
pipeline=off
ser=none
atf=off
#wa=off

#default values for addtional switches for metro
write_thru=on
back_biasing=off
power_gating=off
retention=on

# advanced options
cust_comment=
bus_notation=on
asvm=on
nldm=on
ccs=off
synopsys.ecsm=off
#dnw=off
left_bus_delim=[
right_bus_delim=]
pwr_gnd_rename=VDDPE:VDDPE,VDDCE:VDDCE,VSSE:VSSE
prefix=
name_case=upper
check_instname=off
diodes=on
#inside_ring_type=GND
#vclef-fp.inst2ring=blockages
vclef-fp.site_def=on
#vclef-fp-prelim.inst2ring=blockages
#vclef-fp-prelim.site_def=on
ext.extname=ESTSPC

# view-specific switches which has to be specified
# for plugin views
ambit.libname=USERLIB
synopsys.libname=USERLIB
tlf.libname=USERLIB
udl.libname=USERLIB
wattwatcher.libname=USERLIB
#vhdl.simulator=modelsim
corners=ss_0p90v_0p90v_125c,ss_0p90v_0p90v_m40c,tt_1p00v_1p00v_25c,ff_1p10v_1p10v_m40c,ff_1p10v_1p10v_125c,ff_1p10v_1p10v_0c

# $Revision: 1.1 $
# generic switches
instname= sram_sp_hdc_svt_rvt_hvt
words=2048
bits=16
frequency=1
#ring_width=6
#ring_width_core=6
#ring_width_periphery=6
mux=16
write_mask=off
wp_size=8
top_layer=m5-m9
power_type=otc
#horiz=met3
#vert=met4
drive=6
#bist=off
ema=on
ser=none
bmux=off
pipeline=off
atf=off
#bar_layer=met3
#pin_space=1.0
# generic parameters for redundancy
redundancy=off
rcols=2
rrows=2

#default values for addtional switches for metro
write_thru=on
back_biasing=off
power_gating=off
retention=on

# advanced options
cust_comment=
bus_notation=on
dnw=off
left_bus_delim=[
right_bus_delim=]
pwr_gnd_rename=VDDPE:VDDPE,VDDCE:VDDCE,VSSE:VSSE
prefix=
#pin_space=0.0
name_case=upper
check_instname=off
diodes=on
#inside_ring_type=GND
#vclef-fp.inst2ring=blockages
vclef-fp.site_def=off
#vclef-fp-prelim.inst2ring=blockages
#vclef-fp-prelim.site_def=off

# advanced options for redundancy
asvm=on

# view-specific switches
#testcode.mode=addr

# view-specific switches which has to be specified
# for plugin views
ambit.libname=USERLIB
synopsys.libname=USERLIB
synopsys.nldm=on
synopsys.ccs=off
synopsys.ecsm=off
tlf.libname=USERLIB
udl.libname=USERLIB
wattwatcher.libname=USERLIB
#vhdl.simulator=modelsim
#corners=ff_1p10v_1p10v_m40c,ff_1p10v_1p10v_125c,tt_1p00v_1p00v_25c,ss_0p90v_0p90v_125c
corners=ff_1p10v_1p10v_m40c,ff_1p10v_1p10v_0c,ff_1p10v_1p10v_125c,tt_1p00v_1p00v_25c,ss_0p90v_0p90v_m40c,ss_0p90v_0p90v_125c
ext.extname=ESTSPC

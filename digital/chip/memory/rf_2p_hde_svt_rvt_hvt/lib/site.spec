# generic switches
instname=rf_2p_hde_svt_rvt_hvt
words=32
bits=32
frequency=1
pipeline=off
mux=1
drive=4
top_layer=m5-m9
write_mask=off
wp_size=8
power_type=otc
#horiz=met3
#vert=met2
ema=on
ser=none
bmux=off
pin_space=0.0
redundancy=off
rrows=0
rcols=1

#default values for addtional switches for metro
write_thru=off
back_biasing=off
power_gating=off
retention=on
#weak_bit_test=off
#wbt=off
#rdt=off
#read_disturb_test=off
atf=off
#wa=on


# advanced options
cust_comment=
bus_notation=on
#dnw=off
left_bus_delim=[
right_bus_delim=]
pwr_gnd_rename=VDDPE:VDDPE,VDDCE:VDDCE,VSSE:VSSE
prefix=
name_case=upper
check_instname=off
diodes=on
#inside_ring_type=VSS
#vclef-fp.inst2ring=blockages
vclef-fp.site_def=off
#vclef-fp-prelim.inst2ring=blockages
#vclef-fp-prelim.site_def=off
#advanced switch fr DP Clock Collision
dpccm=on
#advanced switch for read address setup violation
asvm=on

# view-specific switches which has to be specified
# for plugin views
ambit.libname=USERLIB
synopsys.libname=USERLIB
tlf.libname=USERLIB
udl.libname=USERLIB
wattwatcher.libname=USERLIB
synopsys.nldm=on
synopsys.ccs=off
synopsys.ecsm=off
ext.extname=off
#corners=ss_0p90v_125c,ss_1p08v_125c,ff_1p32v_m40c,ff_1p10v_m40c
#corners=ss_0p90v_0p90v_125c,ss_0p90v_0p90v_m40c,tt_1p00v_1p00v_25c,ff_1p10v_1p10v_m40c,ff_1p10v_1p10v_125c,ff_1p10v_1p10v_0c

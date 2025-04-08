# $Revision: 1.3 $
# generic switches
instname=rom_via_hde_hvt_rvt_hvt
words=4096
bits=16
mux=16
frequency=1
code_file=
drive=6
top_layer=m5-m9
#write_mask=off
power_type=otc
#wp_size=8
ema=on
#ser=none
#ser_pipeline=off

#default values for addtional switches for metro
back_biasing=off
power_gating=off
bmux=off

#weak_bit_test
#wbt=off
atf=off

# advanced options
cust_comment=
bus_notation=on
left_bus_delim=[
right_bus_delim=]
pwr_gnd_rename=VDDE:VDD,VSSE:VSS
prefix=
pin_space=0.0
name_case=upper
check_instname=off
diodes=on
#inside_ring_type=VSS
#lef-fp.inst2ring=blockages
lef-fp.site_def=off
#lef-fp-prelim.inst2ring=blockages
#lef-fp-prelim.site_def=off

# advanced options for redundancy
#fuse_encoding=encoded
#insert_fuse=yes
#fusebox_name=FUSE
#rtl_style=mux

# view-specific switches
testcode.mode=addr

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
#corners=ff_1p10v_1p10v_m40c,ff_1p10v_1p10v_0c,ff_1p10v_1p10v_125c,tt_1p00v_1p00v_25c,ss_0p90v_0p90v_m40c,ss_0p90v_0p90v_125c

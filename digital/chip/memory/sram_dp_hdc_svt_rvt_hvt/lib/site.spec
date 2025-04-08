# $Revision: 1.1 $
# generic switches
instname= sram_dp_hdc_svt_rvt_hvt
words=4096
bits=32
frequency=1
mux=16
write_mask=off
wp_size=8
top_layer=m5-m9
power_type=otc
drive=6
ema=on
ser=none
bmux=off
# generic parameters for redundancy
redundancy=off
rcols=2
rrows=2

#default values for addtional switches for metro
write_thru=on
back_biasing=off
power_gating=off
retention=on

#pipeline
pipeline=off

#wbt,rdt
atf=off

# advanced options
cust_comment=
bus_notation=on
dnw=off
nldm=on
ccs=off
ecsm=off
left_bus_delim=[
right_bus_delim=]
pwr_gnd_rename=VDDPE:VDDPE,VDDCE:VDDCE,VSSE:VSSE
prefix=
name_case=upper
check_instname=off
diodes=on

vclef-fp.site_def=on
dpccm=on
asvm=on

ext.extname=ESTSPC
# advanced options for redundancy

# view-specific switches
#testcode.mode=addr

# view-specific switches which has to be specified
# for plugin views
ambit.libname=USERLIB
synopsys.libname=USERLIB
tlf.libname=USERLIB
udl.libname=USERLIB
wattwatcher.libname=USERLIB
corners=ff_1p10v_1p10v_m40c, ff_1p10v_1p10v_125c, ss_0p90v_0p90v_m40c, ss_0p90v_0p90v_125c, ff_1p10v_1p10v_0c, tt_1p00v_1p00v_25c 

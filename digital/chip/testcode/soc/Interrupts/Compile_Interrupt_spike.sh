i=$1

PRJ_DIR="/home/sgohil3/acadia/digital/sim"
TEST_PRJ="/home/sgohil3/acadia/digital/chip/testcode/soc/Interrupts"
cd ${PRJ_DIR}


S_FILE="Interrupt_Int_"$i".s"
ELF_FILE="bin/Interrupt_Int_"$i".elf"

echo $ELF_FILE
echo $S_FILE   

make compile PROG=../chip/testcode/soc/Interrupts/$S_FILE
make spike ELF=${ELF_FILE}
mv sim/spike.log ${TEST_PRJ}/spike_int_$i.log
# make clean


cd -
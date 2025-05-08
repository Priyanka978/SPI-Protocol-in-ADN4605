The SCK is used to clock data in and out of the part. The SDI line is used to write to the registers, and the SDO line is used to read data back from the registers. Data on SDI line is clocked on the rising edge of SCK. Data on SDO changes on the falling
edge of SCK.  The part operates in a slave mode and requires an externally applied serial clock to the SCK input. The serial interface is designed to allow the part to be interfaced to systems that provide a serial clock that is synchronized to the serial data.
There are two types of serial operations, a read and a write. Command words are used to distinguish between a read and a write operation are:
Write Command 0x02 (0000 0010)
Read Command 0x03 (0000 0011)

**Write Operation**
Data is clocked into the registers on the rising edgeof SCK. When the CS line is high, the SDI and SDO lines are in three-state mode. Only when the CS goes from a high to a low does the part accept any data on the SDI line. The 8-bit write
command must precede the register address byte. The register address byte is then followed by the data byte.To allow continuous writes, the address pointer register autoincrements by one without having to load the address pointer
register each time. Subsequent data bytes are written into sequential registers. 
**Read Operation**
To read back from a register, first send the read command followed by the desired register address. Subsequent clock cycles, with CS asserted low, stream data starting from the desired register address onto SDO, MSB first. SDO changes on the falling edge of SCK.
Multiple data reads are possible in SPI interface mode because the address pointer register is auto-incremented. 

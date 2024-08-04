# AES-128 Complete Implementation
This repo contains a complete implementation of the Cipher, InvCipher and KeyExpansion parts of the Advanced Encryption Standard (AES) algorithm, a variant of the Rijndael block cipher. This implementation is designed for 128 bit key and processes data in chunks of 128 bits. 

## Implementations

Two different methodologies have been employed in the design and implementation of AES-128 in VHDL:

### Version 1 (v1) - Resource-Efficient Implementation

- Utilizes controller and datapath logic in Cipher and InvCipher
- Optimized for lower resource utilization
- Suitable for systems with limited resources
- Trade-off: Lower throughput and increased processing time

### Version 2 (v2) - High-Performance Implementation

- Fully pipelined solution
- Utilizes larger area of the FPGA
- Significantly higher throughput and lower latency
- Ideal for high-performance applications

The design was simulated, synthesized and implemented using Xilinx Vivado Suite. In addition, the implementation on hardware was functionally verified using UART interface on Basys3 board with Artix7 architecture. 

## Performance Metrics

| Metric          | v1 (Resource-Efficient)  | v2 (High-Performance)    |
|-----------------|--------------------------|--------------------------|
| Throughput      | 0.156 Gbps / 0.0195 GBps | 12.8 Gbps / 1.6 GBps     |
| Latency         | 82 clock cycles / 820 ns | 40 clock cycles / 400 ns |
| Clock Freq      | 100 MHz                  | 100 MHz                  |


### Utilization Summary
```text
+-------------------------+------+-----------+-------+------+-----------+-------+------+-----------+-------+------+-----------+-------+
|        Slice Logic      |      Cipher Top V1       |      Cipher Top V2       |    Inv Cipher Top V1     |    Inv Cipher Top V2     |
+-------------------------+------+-----------+-------+------+-----------+-------+------+-----------+-------+------+-----------+-------+
|        Site Type        | Used | Available | Util% | Used | Available | Util% | Used | Available | Util% | Used | Available | Util% |
+-------------------------+------+-----------+-------+------+-----------+-------+------+-----------+-------+------+-----------+-------+
| Slice LUTs              | 2001 |     20800 |  9.62 | 5536 |     20800 | 26.62 | 2001 |     20800 |  9.62 | 6476 |     20800 | 31.13 |
|   LUT as Logic          | 2001 |     20800 |  9.62 | 5536 |     20800 | 26.62 | 2001 |     20800 |  9.62 | 6476 |     20800 | 31.13 |
|   LUT as Memory         |    0 |      9600 |  0.00 |    0 |      9600 |  0.00 |    0 |      9600 |  0.00 |    0 |      9600 |  0.00 |
| Slice Registers         | 3902 |     41600 |  9.38 | 6825 |     41600 | 16.41 | 3902 |     41600 |  9.38 | 6825 |     41600 | 16.41 |
|   Register as Flip Flop | 3902 |     41600 |  9.38 | 6825 |     41600 | 16.41 | 3902 |     41600 |  9.38 | 6825 |     41600 | 16.41 |
|   Register as Latch     |    0 |     41600 |  0.00 |    0 |     41600 |  0.00 |    0 |     41600 |  0.00 |    0 |     41600 |  0.00 |
| F7 Muxes                |  176 |     16300 |  1.08 | 1136 |     16300 |  6.97 |  176 |     16300 |  1.08 | 1136 |     16300 |  6.97 |
| F8 Muxes                |    0 |      8150 |  0.00 |  480 |      8150 |  5.89 |    0 |      8150 |  0.00 |  480 |      8150 |  5.89 |
+-------------------------+------+-----------+-------+------+-----------+-------+------+-----------+-------+------+-----------+-------+

+-------------------------+------+-----------+-------+------+-----------+-------+------+-----------+-------+------+-----------+-------+
|        Memory           |      Cipher Top V1       |      Cipher Top V2       |    Inv Cipher Top V1     |    Inv Cipher Top V2     |
+-------------------------+------+-----------+-------+------+-----------+-------+------+-----------+-------+------+-----------+-------+
|        Site Type        | Used | Available | Util% | Used | Available | Util% | Used | Available | Util% | Used | Available | Util% |
+-------------------------+------+-----------+-------+------+-----------+-------+------+-----------+-------+------+-----------+-------+
| Block RAM Tile          |    4 |        50 |  8.00 |   25 |        50 | 50.00 |    4 |        50 |  8.00 |   25 |        50 | 50.00 |
|   RAMB36/FIFO*          |    0 |        50 |  0.00 |    0 |        50 |  0.00 |    0 |        50 |  0.00 |    0 |        50 |  0.00 |
|   RAMB18                |    8 |       100 |  8.00 |   50 |       100 | 50.00 |    8 |       100 |  8.00 |   50 |       100 | 50.00 |
|     RAMB18E1 only       |    8 |           |       |   50 |           |       |    8 |           |       |   50 |           |       |
+-------------------------+------+-----------+-------+------+-----------+-------+------+-----------+-------+------+-----------+-------+
```


## File Structure
```bash
├── v1
│   ├── design
│   │   ├── Cipher
│   │   │   ├── *.vhd
│   │   ├── InvCipher
│   │   │   ├── *.vhd
│   ├── testbench
│   │   ├── *.vhd
│   ├── reports
│   │   ├── synthesis
│   │   ├── implementation
│   └── Basys3_Constraints.xdc
├── v2
│   ├── design
│   │   ├── Cipher
│   │   │   ├── *.vhd
│   │   ├── InvCipher
│   │   │   ├── *.vhd
│   ├── testbench
│   │   ├── *.vhd
│   ├── reports
│   │   ├── synthesis
│   │   ├── implementation
│   └── Basys3_Constraints.xdc
├── cipher_test.py
├── invcipher_test.py
├── readme.md
└── .gitignore
```
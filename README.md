# Tarsier

HDL core for of the Tarsier feature detection and extraction accelerator
If you use this in your own publications, please cite:
```
@inproceedings{multilevel-orb:web, 
    author={Josh Weberruss and Lindsay Kleeman and David Boland and Tom Drummond}, 
    booktitle={2017 27th International Conference on Field Programmable Logic and Applications (FPL)}, 
    title={{FPGA acceleration of multilevel ORB feature extraction for computer vision}}, 
    year={2017}, 
    volume={}, 
    number={}, 
    pages={1-8}, 
    keywords={C++ language;Linux;SLAM (robots);control engineering computing;feature extraction;field programmable gate arrays;operating system kernels;robot vision;Arria V FPGA;CPU;FPGA hardware;GPU;Harris-Stephens corner detector;Linux kernel-mode driver;PCI-Express;computer vision;multilevel ORB feature extraction;robotics applications;Detectors;Feature extraction;Field programmable gate arrays;Graphics processing units;Hardware;Image resolution;Robots}, 
    doi={10.23919/FPL.2017.8056856}, 
    ISSN={}, 
    month={9},
}
```

## Description
The code in this repository represents only the HDL core of the Tarsier system - it does not include the PCI-Express interface described in the paper, or the corresponding driver. The input to the system is a stream of pixels, and the output is a stream of descriptors.

## Setup
Due to licensing restrictions, the ORB row RAM module cannot be included in this source dump. The block RAM is not correctly inferred by Quartus when described with SystemVerilog, and so a megafunction must be used. In order to build and use the Tarsier core, it is necessary to recreate this module. The parameters are shown below:

Parameter | Value
----------|------
Ports | 2
Width | 8 bits
Length | 64 words
Read mode | Unregistered (0 cycles)
Write mode | Registered (1 cycle)

The module interface is:

```verilog
module orb_window_row_ram (
    address_a,
    address_b,
    clock,
    data_a,
    data_b,
    wren_a,
    wren_b,
    q_a,
    q_b);

    input	[5:0]  address_a;
    input	[5:0]  address_b;
    input	       clock;
    input	[7:0]  data_a;
    input	[7:0]  data_b;
    input	       wren_a;
    input	       wren_b;
    output	[7:0]  q_a;
    output	[7:0]  q_b;

    ...
endmodule
```
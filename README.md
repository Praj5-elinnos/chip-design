# Advanced Chip Design Repository

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)](https://github.com/Praj5-elinnos/chip-design)
[![License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)
[![SystemVerilog](https://img.shields.io/badge/language-SystemVerilog-orange)](https://github.com/Praj5-elinnos/chip-design)
[![RISC-V](https://img.shields.io/badge/ISA-RISC--V-red)](https://riscv.org/)

A comprehensive repository for digital chip design, featuring a 32-bit RISC-V CPU core, advanced memory controller, and professional VLSI development flow. This project demonstrates industry-standard RTL design practices and verification methodologies.

## 🚀 Features

- **32-bit RISC-V CPU Core**: Pipelined processor with performance optimizations
- **Advanced Memory Controller**: High-performance cache-enabled memory subsystem
- **Professional Build Flow**: Makefile-based automation with multiple tool support
- **Comprehensive Testing**: SystemVerilog testbenches and verification
- **Multiple Simulators**: Support for Verilator, ModelSim, and Vivado

## 📁 Project Structure

```
chip-design/
├── src/
│   ├── rtl/
│   │   ├── cpu_core.sv           # 32-bit RISC-V CPU implementation
│   │   └── memory_controller.sv  # Cache-enabled memory controller
│   └── counter.v                 # Simple counter module
├── tb/
│   └── cpu_testbench.sv          # CPU core testbench
├── scripts/
│   └── run_simulation.py         # Automated simulation runner
├── work/                         # Build and simulation artifacts
├── test/                         # Test automation
├── Makefile                      # Professional build system
└── README.md                     # This file
```

## 🛠️ Prerequisites

### Required Tools
- **Verilator** - For lint checking and C++ simulation
- **ModelSim/QuestaSim** - For advanced simulation (optional)
- **Vivado** - For FPGA synthesis and implementation (optional)
- **Python 3** - For automation scripts
- **Make** - For build automation

### Installation
```bash
# Clone the repository
git clone https://github.com/Praj5-elinnos/chip-design.git
cd chip-design

# Check available make targets
make help
```

## 🏃‍♂️ Quick Start

### Basic Simulation
```bash
# Run Verilator simulation
make verilator

# Run with waveform generation
make verilator-wave

# Clean build artifacts
make clean
```

### Advanced Workflows
```bash
# Run comprehensive verification
make verify

# Generate synthesis reports
make synth

# Run performance analysis
make perf
```

## 🧠 Design Modules

### CPU Core (`src/rtl/cpu_core.sv`)
- **Architecture**: 32-bit RISC-V RV32I compatible
- **Pipeline**: 5-stage with hazard detection and forwarding
- **Features**: 
  - Configurable data/address width (8-32 bits)
  - Separate instruction and data memory interfaces
  - Hardware performance counters
  - JTAG debug interface support
  - Branch prediction unit
  - Exception handling mechanism

### Memory Controller (`src/rtl/memory_controller.sv`)
- **Type**: Cache-enabled memory subsystem
- **Cache**: 4-way set associative, write-back policy
- **Features**:
  - Configurable cache size (4KB-64KB)
  - Dual-port CPU and external memory interfaces
  - Performance optimization with prefetch buffer
  - ECC (Error Correction Code) support
  - Memory mapped I/O support
  - Cache coherency protocols

### Supporting Modules
- **Counter** (`src/counter.v`): Parameterizable up/down counter with overflow detection
- **Clock Generator** (`simple_clock.v`): PLL-based clock generation with frequency dividers

## ⚡ Technical Specifications

### CPU Core Specifications
| Parameter | Value | Description |
|-----------|-------|-------------|
| ISA | RISC-V RV32I | 32-bit base integer instruction set |
| Pipeline Stages | 5 | IF, ID, EX, MEM, WB |
| GPRs | 32 × 32-bit | General purpose registers |
| Clock Frequency | 100 MHz | Target frequency for FPGA |
| Memory Bus Width | 32-bit | Data and instruction buses |
| Cache Line Size | 64 bytes | L1 cache line size |

### Memory Controller Specifications  
| Parameter | Value | Description |
|-----------|-------|-------------|
| Cache Type | L1 Data + Instruction | Split cache architecture |
| Cache Size | 16KB each | Configurable per cache |
| Associativity | 4-way | Set associative mapping |
| Block Size | 64 bytes | Cache block/line size |
| Write Policy | Write-back | With write allocate |
| Memory Bandwidth | 800 MB/s | Peak theoretical bandwidth |

## 📊 Simulation & Testing

### Testbench Coverage
- **CPU Testbench**: Comprehensive instruction set testing
- **Memory Tests**: Cache behavior and performance validation
- **Integration Tests**: Full system verification

### Simulation Tools Support
| Tool | Status | Features |
|------|---------|-----------|
| Verilator | ✅ Primary | Fast, C++ based, coverage |
| ModelSim | ✅ Supported | Advanced debugging, waves |
| Vivado | ✅ Supported | FPGA synthesis, timing |

## 🔧 Build System

The Makefile provides a professional development flow:

```bash
make help          # Show all available targets
make lint          # Run design rule checks
make sim           # Run basic simulation
make coverage      # Generate coverage reports
make synth         # Run synthesis
make clean         # Clean all artifacts
make distclean     # Deep clean including work directory
```

## 📈 Performance Metrics

The design includes performance monitoring:
- Clock frequency optimization targets
- Cache hit/miss ratios
- Pipeline efficiency metrics
- Resource utilization reports

## 🤝 Contributing

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Development Guidelines
- Follow SystemVerilog best practices
- Include comprehensive testbenches
- Document all module interfaces
- Run lint checks before committing
- Maintain backward compatibility

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Chip Design Team** - [Praj5-elinnos](https://github.com/Praj5-elinnos)

## 📋 Changelog

### v2.1.0 (Latest) - December 2024
- ✨ Enhanced CPU core with improved pipeline efficiency
- ⚡ Optimized memory controller cache algorithms
- 🔧 Professional Makefile with comprehensive build targets
- 📊 Added performance monitoring and metrics collection
- 🧪 Expanded testbench coverage for better verification
- 📚 Comprehensive documentation updates

### v2.0.0 - November 2024
- 🚀 Major rewrite with SystemVerilog
- 💾 Advanced cache-enabled memory controller
- 🔄 Multi-stage pipeline implementation
- 🛠️ Integration with multiple simulation tools
- ⚡ Performance optimizations and analysis tools

### v1.0.0 - October 2024
- 🎉 Initial release with basic RISC-V CPU core
- 📦 Simple counter and basic modules
- 🧪 Basic testbench infrastructure
- 🏗️ Foundation build system

## 🔮 Roadmap

### Planned Features
- [ ] **Vector Extension**: RISC-V Vector (RVV) support
- [ ] **Debug Module**: Full RISC-V Debug Spec compliance  
- [ ] **Interrupt Controller**: PLIC implementation
- [ ] **Memory Protection**: MMU with virtual memory
- [ ] **Bus Interface**: AXI4 and Wishbone support
- [ ] **Formal Verification**: SystemVerilog Assertions (SVA)

### Target Platforms
- [ ] **Xilinx Zynq**: FPGA implementation
- [ ] **Intel Cyclone**: FPGA synthesis  
- [ ] **SkyWater 130nm**: Open source ASIC flow
- [ ] **Verilator**: High-performance simulation

## 🙏 Acknowledgments

- Open source EDA tools community
- RISC-V Foundation for ISA specifications
- SystemVerilog and UVM methodology guides
- Digital design best practices from industry standards
- ChipDesigner IDE development team

## 📞 Support

For questions, issues, or contributions:
- 📧 Open an [Issue](https://github.com/Praj5-elinnos/chip-design/issues)
- 💬 Start a [Discussion](https://github.com/Praj5-elinnos/chip-design/discussions)

---

**⭐ Star this repository if it helps with your chip design projects!**
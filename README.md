# Advanced Chip Design Repository

A comprehensive repository for digital chip design, featuring a 32-bit RISC-V CPU core, advanced memory controller, and professional VLSI development flow.

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
- **Architecture**: 32-bit RISC-V compatible
- **Pipeline**: Multi-stage with hazard detection
- **Features**: 
  - Configurable data/address width
  - Instruction and data memory interfaces
  - Performance counters
  - Debug interface support

### Memory Controller (`src/rtl/memory_controller.sv`)
- **Type**: Cache-enabled memory subsystem
- **Cache**: 4-way set associative
- **Features**:
  - Configurable cache size
  - CPU and external memory interfaces
  - Performance optimization
  - Error detection and correction

### Supporting Modules
- **Counter** (`src/counter.v`): Parameterizable up counter
- **Clock Generator** (`simple_clock.v`): Clock generation utilities

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

## 🙏 Acknowledgments

- Open source EDA tools community
- RISC-V Foundation for ISA specifications
- SystemVerilog and UVM methodology guides
- Digital design best practices from industry standards

## 📞 Support

For questions, issues, or contributions:
- 📧 Open an [Issue](https://github.com/Praj5-elinnos/chip-design/issues)
- 💬 Start a [Discussion](https://github.com/Praj5-elinnos/chip-design/discussions)

---

**⭐ Star this repository if it helps with your chip design projects!**
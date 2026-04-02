# Chip Design Repository

A comprehensive repository for digital chip design, containing RTL modules, testbenches, and design verification components.

## Table of Contents
1. [Getting Started](#getting-started)
2. [Project Structure](#project-structure)
3. [Design Modules](#design-modules)
4. [Simulation](#simulation)
5. [Contributing](#contributing)
6. [License](#license)

## Getting Started

### Prerequisites
- Icarus Verilog (iverilog) for simulation
- GTKWave for waveform viewing
- Make for build automation

### Installation
```bash
git clone <repository-url>
cd chip-design
make help  # See available commands
```

## Project Structure
```
chip-design/
├── src/           # RTL source files
├── tb/            # Testbench files
├── scripts/       # Build and automation scripts
├── test/          # Test cases and verification
├── work/          # Simulation working directory
└── Makefile       # Build automation
```

## Design Modules
- **Counter**: Simple up counter with configurable width
- **Clock Generator**: Simple clock generation module
- **Module with Class**: SystemVerilog module demonstrating OOP concepts

## Simulation
Run simulations using the provided Makefile:
```bash
make sim MODULE=counter      # Simulate counter module
make clean                   # Clean generated files
make help                    # Show available targets
```

## Contributing
1. Fork the repository
2. Create a feature branch
3. Add your RTL modules and testbenches
4. Test your design thoroughly
5. Submit a pull request

## License
This project is released under the MIT License.

## Authors
Chip Design Team

## Acknowledgments
- Open source EDA tools community
- Digital design best practices from industry standards
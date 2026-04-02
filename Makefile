# Advanced Chip Design Makefile
# Professional VLSI development flow

# Project Configuration
PROJECT_NAME = advanced_cpu
RTL_DIR = src/rtl
TB_DIR = tb
SCRIPTS_DIR = scripts
BUILD_DIR = build
RESULTS_DIR = results

# Tool Configuration
VERILATOR = verilator
MODELSIM = vsim
VIVADO = vivado
PYTHON = python3

# RTL Sources
RTL_SOURCES = $(RTL_DIR)/cpu_core.sv \
              $(RTL_DIR)/memory_controller.sv

# Testbench
TESTBENCH = $(TB_DIR)/cpu_testbench.sv
TOP_MODULE = cpu_testbench

# Verilator Flags
VERILATOR_FLAGS = -Wall -Wno-fatal --cc --exe --build
VERILATOR_FLAGS += --top-module $(TOP_MODULE)
VERILATOR_FLAGS += --trace --coverage --coverage-line
VERILATOR_FLAGS += -CFLAGS "-std=c++14 -O2"

# Default target
.PHONY: all
all: clean compile simulate report

# Clean build artifacts
.PHONY: clean
clean:
	@echo "🧹 Cleaning build artifacts..."
	rm -rf $(BUILD_DIR) $(RESULTS_DIR) obj_dir coverage waves
	rm -f *.vcd *.dat *.log

# Setup directories
.PHONY: setup
setup:
	@echo "📁 Setting up directories..."
	mkdir -p $(BUILD_DIR) $(RESULTS_DIR) coverage waves

# Compile with Verilator
.PHONY: compile
compile: setup
	@echo "🔨 Compiling RTL with Verilator..."
	$(VERILATOR) $(VERILATOR_FLAGS) $(RTL_SOURCES) $(TESTBENCH)

# Alternative: Compile with ModelSim
.PHONY: compile-modelsim
compile-modelsim: setup
	@echo "🔨 Compiling RTL with ModelSim..."
	vlib work
	vlog -sv $(RTL_SOURCES) $(TESTBENCH)

# Run simulation
.PHONY: simulate
simulate:
	@echo "🚀 Running simulation..."
	./obj_dir/V$(TOP_MODULE)

# Run with ModelSim
.PHONY: simulate-modelsim
simulate-modelsim:
	@echo "🚀 Running simulation with ModelSim..."
	$(MODELSIM) -c -do "run -all; quit" $(TOP_MODULE)

# Advanced simulation with Python runner
.PHONY: sim
sim: setup
	@echo "🎯 Running advanced simulation flow..."
	$(PYTHON) $(SCRIPTS_DIR)/run_simulation.py

# Generate coverage report
.PHONY: coverage
coverage:
	@echo "📊 Generating coverage report..."
	verilator_coverage --annotate coverage/ --write-info coverage/coverage.info coverage.dat
	@echo "Coverage report generated in coverage/"

# View waveforms
.PHONY: waves
waves:
	@echo "📈 Opening waveforms..."
	gtkwave cpu_simulation.vcd &

# Synthesis with Vivado
.PHONY: synthesis
synthesis:
	@echo "⚡ Running synthesis..."
	$(VIVADO) -mode batch -source scripts/synthesis.tcl

# Generate documentation
.PHONY: docs
docs:
	@echo "📚 Generating documentation..."
	doxygen Doxyfile

# Lint RTL code
.PHONY: lint
lint:
	@echo "🔍 Linting RTL code..."
	verilator --lint-only $(RTL_SOURCES)

# Format code
.PHONY: format
format:
	@echo "✨ Formatting code..."
	find $(RTL_DIR) $(TB_DIR) -name "*.sv" -exec verible-verilog-format --inplace {} \;

# Run regression tests
.PHONY: regression
regression: clean
	@echo "🧪 Running regression tests..."
	for test in tests/*.py; do \
		echo "Running $$test..."; \
		$(PYTHON) $$test || exit 1; \
	done

# Performance analysis
.PHONY: perf
perf: simulate
	@echo "⚡ Analyzing performance..."
	$(PYTHON) $(SCRIPTS_DIR)/performance_analyzer.py $(RESULTS_DIR)/report.json

# Generate test report
.PHONY: report
report:
	@echo "📋 Generating test report..."
	@if [ -f $(RESULTS_DIR)/report.json ]; then \
		echo "✅ Report available at $(RESULTS_DIR)/report.html"; \
	else \
		echo "⚠️  No simulation results found. Run 'make sim' first."; \
	fi

# Install dependencies
.PHONY: install-deps
install-deps:
	@echo "📦 Installing dependencies..."
	sudo apt-get update
	sudo apt-get install -y verilator gtkwave
	pip3 install -r requirements.txt

# Quick test
.PHONY: test
test: compile simulate
	@echo "✅ Quick test completed"

# Full verification flow
.PHONY: verify
verify: clean lint compile simulate coverage report
	@echo "🎉 Full verification flow completed!"

# Continuous integration target
.PHONY: ci
ci: clean compile simulate
	@echo "🤖 CI verification completed"
	@if [ -f $(RESULTS_DIR)/report.json ]; then \
		$(PYTHON) -c "import json; r=json.load(open('$(RESULTS_DIR)/report.json')); exit(0 if r['results'].get('failed',1)==0 else 1)"; \
	else \
		exit 1; \
	fi

# Help target
.PHONY: help
help:
	@echo "🚀 Advanced Chip Design Makefile"
	@echo "=================================="
	@echo ""
	@echo "Main targets:"
	@echo "  all          - Clean, compile, simulate, and report"
	@echo "  compile      - Compile RTL with Verilator"
	@echo "  simulate     - Run simulation"
	@echo "  sim          - Advanced simulation with Python runner"
	@echo "  coverage     - Generate coverage report"
	@echo "  waves        - View waveforms with GTKWave"
	@echo "  synthesis    - Run synthesis with Vivado"
	@echo "  lint         - Lint RTL code"
	@echo "  format       - Format code"
	@echo "  test         - Quick compile and simulate"
	@echo "  verify       - Full verification flow"
	@echo "  clean        - Clean build artifacts"
	@echo "  help         - Show this help"
	@echo ""
	@echo "Alternative tools:"
	@echo "  compile-modelsim    - Compile with ModelSim"
	@echo "  simulate-modelsim   - Simulate with ModelSim"
	@echo ""
	@echo "Analysis:"
	@echo "  perf         - Performance analysis"
	@echo "  regression   - Run regression tests"
	@echo "  docs         - Generate documentation"
	@echo ""
	@echo "Setup:"
	@echo "  install-deps - Install required dependencies"

# Default shell
SHELL := /bin/bash
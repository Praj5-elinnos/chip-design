#!/usr/bin/env python3
"""
Advanced Simulation Runner
Automated chip design verification flow
"""

import os
import sys
import subprocess
import argparse
import json
import time
from pathlib import Path
from typing import Dict, List, Optional

class SimulationRunner:
    def __init__(self, config_file: Optional[str] = None):
        self.config = self.load_config(config_file)
        self.results = {}
        self.start_time = time.time()
        
    def load_config(self, config_file: Optional[str]) -> Dict:
        """Load simulation configuration"""
        default_config = {
            "simulator": "verilator",
            "rtl_files": [
                "src/rtl/cpu_core.sv",
                "src/rtl/memory_controller.sv"
            ],
            "testbench": "tb/cpu_testbench.sv",
            "top_module": "cpu_testbench",
            "compile_flags": ["-Wall", "-Wno-fatal"],
            "sim_flags": ["+vcd"],
            "coverage": True,
            "waves": True,
            "timeout": 10000
        }
        
        if config_file and os.path.exists(config_file):
            with open(config_file, 'r') as f:
                user_config = json.load(f)
                default_config.update(user_config)
                
        return default_config
    
    def setup_directories(self):
        """Create necessary directories"""
        dirs = ["build", "results", "coverage", "waves"]
        for d in dirs:
            Path(d).mkdir(exist_ok=True)
            
    def compile_rtl(self) -> bool:
        """Compile RTL with Verilator"""
        print("🔨 Compiling RTL...")
        
        cmd = ["verilator"]
        cmd.extend(self.config["compile_flags"])
        cmd.extend(["--cc", "--exe"])
        cmd.extend(self.config["rtl_files"])
        cmd.append(self.config["testbench"])
        cmd.extend(["--top-module", self.config["top_module"]])
        cmd.extend(["-o", "build/sim"])
        
        if self.config["coverage"]:
            cmd.extend(["--coverage", "--coverage-line"])
            
        if self.config["waves"]:
            cmd.append("--trace")
            
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, cwd=".")
            if result.returncode != 0:
                print(f"❌ Compilation failed:")
                print(result.stderr)
                return False
            print("✅ Compilation successful")
            return True
        except Exception as e:
            print(f"❌ Compilation error: {e}")
            return False
    
    def run_simulation(self) -> bool:
        """Run the simulation"""
        print("🚀 Running simulation...")
        
        # Build the executable
        make_cmd = ["make", "-C", "obj_dir", "-f", "Vcpu_testbench.mk", "Vcpu_testbench"]
        try:
            result = subprocess.run(make_cmd, capture_output=True, text=True)
            if result.returncode != 0:
                print(f"❌ Build failed: {result.stderr}")
                return False
        except Exception as e:
            print(f"❌ Build error: {e}")
            return False
            
        # Run simulation
        sim_cmd = ["./obj_dir/Vcpu_testbench"]
        sim_cmd.extend(self.config.get("sim_flags", []))
        
        try:
            result = subprocess.run(sim_cmd, capture_output=True, text=True, 
                                  timeout=self.config["timeout"])
            
            # Save simulation output
            with open("results/simulation.log", "w") as f:
                f.write(result.stdout)
                f.write(result.stderr)
                
            if result.returncode == 0:
                print("✅ Simulation completed successfully")
                self.parse_results(result.stdout)
                return True
            else:
                print(f"❌ Simulation failed with return code {result.returncode}")
                print(result.stderr)
                return False
                
        except subprocess.TimeoutExpired:
            print(f"⏰ Simulation timed out after {self.config['timeout']} seconds")
            return False
        except Exception as e:
            print(f"❌ Simulation error: {e}")
            return False
    
    def parse_results(self, output: str):
        """Parse simulation output for results"""
        lines = output.split('\n')
        
        for line in lines:
            if "Total Tests:" in line:
                self.results["total_tests"] = int(line.split(":")[1].strip())
            elif "Passed:" in line:
                self.results["passed"] = int(line.split(":")[1].strip())
            elif "Failed:" in line:
                self.results["failed"] = int(line.split(":")[1].strip())
            elif "Coverage:" in line:
                coverage_str = line.split(":")[1].strip().replace("%", "")
                self.results["coverage"] = float(coverage_str)
            elif "Cache Statistics:" in line:
                self.results["cache_stats"] = {}
            elif "Total Accesses:" in line:
                self.results["cache_stats"]["total_accesses"] = int(line.split(":")[1].strip())
            elif "Hit Rate:" in line:
                hit_rate_str = line.split(":")[1].strip().replace("%", "")
                self.results["cache_stats"]["hit_rate"] = float(hit_rate_str)
    
    def generate_coverage_report(self):
        """Generate coverage report"""
        if not self.config["coverage"]:
            return
            
        print("📊 Generating coverage report...")
        
        # Convert coverage data
        try:
            subprocess.run(["verilator_coverage", "--annotate", "coverage/", 
                          "--write-info", "coverage/coverage.info", "coverage.dat"],
                         check=True)
            print("✅ Coverage report generated in coverage/")
        except subprocess.CalledProcessError:
            print("⚠️  Coverage report generation failed")
    
    def move_artifacts(self):
        """Move simulation artifacts to results directory"""
        artifacts = {
            "cpu_simulation.vcd": "waves/",
            "coverage.dat": "coverage/",
            "obj_dir/": "build/"
        }
        
        for src, dst in artifacts.items():
            if os.path.exists(src):
                try:
                    if os.path.isdir(src):
                        subprocess.run(["cp", "-r", src, dst], check=True)
                    else:
                        subprocess.run(["cp", src, dst], check=True)
                except subprocess.CalledProcessError:
                    pass  # Ignore copy errors
    
    def generate_report(self):
        """Generate final test report"""
        duration = time.time() - self.start_time
        
        report = {
            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
            "duration": f"{duration:.2f}s",
            "config": self.config,
            "results": self.results
        }
        
        # Save JSON report
        with open("results/report.json", "w") as f:
            json.dump(report, f, indent=2)
        
        # Generate HTML report
        html_report = self.generate_html_report(report)
        with open("results/report.html", "w") as f:
            f.write(html_report)
        
        print(f"\n📋 SIMULATION REPORT")
        print("=" * 50)
        print(f"Duration: {duration:.2f}s")
        print(f"Total Tests: {self.results.get('total_tests', 'N/A')}")
        print(f"Passed: {self.results.get('passed', 'N/A')}")
        print(f"Failed: {self.results.get('failed', 'N/A')}")
        print(f"Coverage: {self.results.get('coverage', 'N/A')}%")
        
        if "cache_stats" in self.results:
            stats = self.results["cache_stats"]
            print(f"Cache Hit Rate: {stats.get('hit_rate', 'N/A')}%")
        
        print(f"\n📁 Results saved to: results/")
        
    def generate_html_report(self, report: Dict) -> str:
        """Generate HTML report"""
        return f"""
<!DOCTYPE html>
<html>
<head>
    <title>Chip Design Simulation Report</title>
    <style>
        body {{ font-family: Arial, sans-serif; margin: 40px; }}
        .header {{ background: #2c3e50; color: white; padding: 20px; border-radius: 5px; }}
        .section {{ margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }}
        .pass {{ color: #27ae60; }}
        .fail {{ color: #e74c3c; }}
        .metric {{ display: inline-block; margin: 10px; padding: 10px; background: #ecf0f1; border-radius: 3px; }}
    </style>
</head>
<body>
    <div class="header">
        <h1>🚀 Chip Design Simulation Report</h1>
        <p>Generated: {report['timestamp']}</p>
        <p>Duration: {report['duration']}</p>
    </div>
    
    <div class="section">
        <h2>📊 Test Results</h2>
        <div class="metric">Total Tests: {report['results'].get('total_tests', 'N/A')}</div>
        <div class="metric pass">Passed: {report['results'].get('passed', 'N/A')}</div>
        <div class="metric fail">Failed: {report['results'].get('failed', 'N/A')}</div>
        <div class="metric">Coverage: {report['results'].get('coverage', 'N/A')}%</div>
    </div>
    
    <div class="section">
        <h2>🎯 Performance Metrics</h2>
        {self._format_cache_stats_html(report['results'].get('cache_stats', {}))}
    </div>
    
    <div class="section">
        <h2>⚙️  Configuration</h2>
        <pre>{json.dumps(report['config'], indent=2)}</pre>
    </div>
</body>
</html>
        """
    
    def _format_cache_stats_html(self, stats: Dict) -> str:
        if not stats:
            return "<p>No cache statistics available</p>"
        
        return f"""
        <div class="metric">Total Accesses: {stats.get('total_accesses', 'N/A')}</div>
        <div class="metric">Hit Rate: {stats.get('hit_rate', 'N/A')}%</div>
        """
    
    def run_full_flow(self) -> bool:
        """Run complete simulation flow"""
        print("🎯 Starting Advanced Chip Design Simulation Flow")
        print("=" * 60)
        
        self.setup_directories()
        
        if not self.compile_rtl():
            return False
            
        if not self.run_simulation():
            return False
            
        self.generate_coverage_report()
        self.move_artifacts()
        self.generate_report()
        
        success = self.results.get('failed', 1) == 0
        if success:
            print("\n🎉 SIMULATION FLOW COMPLETED SUCCESSFULLY!")
        else:
            print(f"\n❌ SIMULATION FLOW COMPLETED WITH {self.results.get('failed', 'UNKNOWN')} FAILURES")
            
        return success

def main():
    parser = argparse.ArgumentParser(description="Advanced Chip Design Simulation Runner")
    parser.add_argument("--config", help="Configuration file path")
    parser.add_argument("--simulator", choices=["verilator", "modelsim", "vivado"], 
                       default="verilator", help="Simulator to use")
    parser.add_argument("--no-coverage", action="store_true", help="Disable coverage collection")
    parser.add_argument("--no-waves", action="store_true", help="Disable waveform generation")
    
    args = parser.parse_args()
    
    # Create runner
    runner = SimulationRunner(args.config)
    
    # Override config with command line args
    if args.simulator:
        runner.config["simulator"] = args.simulator
    if args.no_coverage:
        runner.config["coverage"] = False
    if args.no_waves:
        runner.config["waves"] = False
    
    # Run simulation flow
    success = runner.run_full_flow()
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
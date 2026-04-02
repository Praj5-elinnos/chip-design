#!/usr/bin/env python3
"""
Simple Python script example
"""

def main():
    print("Hello, World!")
    numbers = [1, 2, 3, 4, 5]
    squared = [x**2 for x in numbers]
    print(f"Original numbers: {numbers}")
    print(f"Squared numbers: {squared}")

if __name__ == "__main__":
    main() 
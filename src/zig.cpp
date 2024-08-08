#include <format>
#include <iostream>
// #include <print>

#include <cosmo.h>

// https://github.com/jart/cosmopolitan/issues/166
// Force it to be a zip too.
STATIC_YOINK("__zip_start")

int main() {
  std::cout << std::format("Hello {}!", "Alan Turing") << "\n";
//   std::println("Hello {}!", "Ada Lovelace");
  return 0;
}

// cosmoc++ -std=c++23 doesn't work with std::format() or std::println().
// TODO: Figure out a way around this for dependencies that use these functions.
cmake_minimum_required(VERSION 3.9)
project(inf4_proj_dev_C C)

set(CMAKE_C_STANDARD 99)
add_executable(inf4_proj_dev_C main.c)
target_link_libraries(inf4_proj_dev_C pthread)
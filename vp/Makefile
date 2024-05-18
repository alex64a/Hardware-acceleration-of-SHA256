# Specify the compiler
CC = g++

# Specify compiler flags
CFLAGS = -Wall -Wextra

# Specify the SystemC library path
SYSTEMC_HOME = /usr/local/system-2.3.1
# Specify the include directories
INCLUDES = -I$(SYSTEMC_HOME)/include

# Specify the library directories
LIB_DIRS = -L$(SYSTEMC_HOME)/lib-linux64 

# Specify the libraries to link against
LIBS = -lsystemc -lm

# Specify the source files
SRCS = $(wildcard *.cpp)

# Specify the object files
OBJS = $(SRCS:.cpp=.o)

# Specify the executable name
EXE = main

.PHONY:all
all:
	$(MAKE) -j10 $(EXE)

# Build rule for the executable
$(EXE): $(OBJS)
	$(CC) $(CFLAGS) $(INCLUDES) $(LIB_DIRS) -o $@ $(OBJS) $(LIBS)

# Build rule for object files
%.o: %.cpp
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

# Clean rule
clean:
	rm -f $(OBJS) $(EXE)

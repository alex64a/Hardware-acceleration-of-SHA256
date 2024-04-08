CC = g++
CFLAGS = -std=c++11 -Wall

# Source files
SRCS = sha256.cpp main.cpp

# Object files
OBJS = $(SRCS:.cpp=.o)

# Executable name
EXEC = sha256

all: $(EXEC)

$(EXEC): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^

%.o: %.cpp
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: clean

clean:
	rm -f $(OBJS) $(EXEC)


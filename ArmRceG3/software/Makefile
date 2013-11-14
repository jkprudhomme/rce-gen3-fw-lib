# Variables
CFLAGS  := -Wall 
LFLAGS  := -lrt -pthread 
CC      := g++ -fpermissive 
BIN     := $(PWD)/bin
OBJ     := $(PWD)/.obj

# Generic Sources
LIB_DIR := $(PWD)/lib
LIB_SRC := $(wildcard $(LIB_DIR)/*.cpp)
LIB_HDR := $(wildcard $(LIB_DIR)/*.h)
LIB_OBJ := $(patsubst $(LIB_DIR)/%.cpp,$(OBJ)/%.o,$(LIB_SRC))

# Common Sources
COM_DIR := $(PWD)/../common/
COM_SRC := $(wildcard $(COM_DIR)/*.cpp)
COM_HDR := $(wildcard $(COM_DIR)/*.h)
COM_OBJ := $(patsubst $(COM_DIR)/%.cpp,$(OBJ)/%.o,$(COM_SRC))

# Top Sources
TOP_DIR := $(PWD)/src
TOP_SRC := $(wildcard $(TOP_DIR)/*.cpp)
TOP_BIN := $(patsubst $(TOP_DIR)/%.cpp,$(BIN)/%,$(TOP_SRC))

# Default
all: dir $(LIB_OBJ) $(COM_OBJ) $(TOP_BIN)

# Object directory
dir:
	test -d $(OBJ) || mkdir $(OBJ)

# Clean
clean:
	rm -f $(OBJ)/*
	rm -f $(BIN)/*

# Compile Library Sources
$(OBJ)/%.o: $(LIB_DIR)/%.cpp $(LIB_DIR)/%.h
	$(CC) -c $(CFLAGS) $(DEF) -o $@ $<

# Compile Library Sources
$(OBJ)/%.o: $(COM_DIR)/%.cpp $(COM_DIR)/%.h
	$(CC) -c $(CFLAGS) $(DEF) -o $@ $<

# Comile applications
$(BIN)/%: $(TOP_DIR)/%.cpp $(LIB_OBJ)
	$(CC) $(CFLAGS) $(DEF) $(OBJ)/*.o -o $@ $< $(LFLAGS) 


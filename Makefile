ARCH ?= $(shell uname -m)
OS   ?= $(shell uname -s)

CXXFLAGS = -std=c++11 -O3 -march=native -mtune=native
CFLAGS = -std=c11 -O3 -march=native -mtune=native

JSONCPP_CFLAGS ?= $(shell pkg-config --cflags jsoncpp)
JSONCPP_LDFLAGS ?= $(shell pkg-config --libs jsoncpp)
CXXFLAGS += $(JSONCPP_CFLAGS)
LDFLAGS += $(JSONCPP_LDFLAGS)

DIVSUFSORT_CFLAGS  ?= $(shell pkg-config --cflags libdivsufsort)
DIVSUFSORT_LDFLAGS ?= $(shell pkg-config --libs libdivsufsort)
# DIVSUFSORT_CFLAGS ?= -I../contrib/libdivsufsort/
CXXFLAGS += $(DIVSUFSORT_CFLAGS)
LDFLAGS  += $(DIVSUFSORT_LDFLAGS)

MPFR_CFLAGS  ?= $(shell pkg-config --cflags mpfr)
MPFR_LDFLAGS ?= $(shell pkg-config --libs mpfr)
CXXFLAGS += $(MPFR_CFLAGS)
LDFLAGS  += $(MPFR_LDFLAGS)

GMP_CFLAGS  ?= $(shell pkg-config --cflags gmp)
GMP_LDFLAGS ?= $(shell pkg-config --libs gmp)
CXXFLAGS += $(GMP_CFLAGS)
LDFLAGS  += $(GMP_LDFLAGS)

ifeq ($(OS), Darwin)
# OPENSSL_PREFIX  ?= $(shell brew --prefix)/opt/openssl@1.1/
CXXFLAGS += -Xclang -fopenmp -Wno-deprecated-declarations
LDFLAGS  += -lomp
else
# OPENSSL_PREFIX  ?= /usr/local
CXXFLAGS += -fopenmp
LDFLAGS  += -fopenmp
endif

# OPENSSL_CFLAGS  ?= -I$(OPENSSL_PREFIX)/include
# OPENSSL_LDFLAGS ?= -L$(OPENSSL_PREFIX)/lib -lcrypto
OPENSSL_CFLAGS  ?= $(shell pkg-config --cflags libcrypto)
OPENSSL_LDFLAGS ?= $(shell pkg-config --libs libcrypto)
CXXFLAGS += $(OPENSSL_CFLAGS)
LDFLAGS  += $(OPENSSL_LDFLAGS)

ifeq ($(ARCH),x86)
CXXFLAGS += -msse2 -ffloat-store
endif

#CXX = clang++-15
#CXXFLAGS = -g -Wno-padded -Wno-disabled-macro-expansion -Wno-gnu-statement-expression -Wno-bad-function-cast -fopenmp -O1 -fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer -fdenormal-fp-math=ieee -msse2 -march=native -I/usr/include/jsoncpp
#static analysis in clang using
#scan-build-15 --use-c++=/usr/bin/clang++-15 make
COND_CXXFLAGS = $(CXXFLAGS) $(MPFR_LDFLAGS) $(GMP_CFLAGS)
COND_LDFLAGS  = $(LDFLAGS) $(MPFR_CFLAGS) $(GMP_LDFLAGS)

LDFLAGS += -lbz2 -lpthread

LIB_PREFIX ?= lib
LIB_SUFFIX ?= .a
SHLIB_LDFLAGS ?= -shared -fPIC

ifeq ($(SHLIB_SUFFIX),)
ifeq ($(OS),Darwin)
	SHLIB_SUFFIX=.dylib
else
	SHLIB_SUFFIX=.so
endif
endif


ifeq ($(OS),Darwin)
	SHLIB_LDFLAGS += -undefined dynamic_lookup
else
	SHLIB_SUFFIX=.so
	SHLIB_LDFLAGS += -Wl,-soname,$(SHARED_LIB)
endif


######
# Main operations
######

all: iid non_iid restart conditioning transpose

clean:
	rm -f *.o ea_iid ea_non_iid ea_restart ea_conditioning ea_transpose selftest/*.res

%.o: cpp/%.cpp
	$(CXX) $(CXXFLAGS) $< -c -o $@

%.o: %.c
	$(CC) $(CFLAGS) $< -c -o $@

# divsufsort.o: ../contrib/libdivsufsort/sssort.c ../contrib/libdivsufsort/trsort.c ../contrib/libdivsufsort/divsufsort.c
# 	$(CC) $(CFLAGS) -c $^

iid: iid_main.o
	$(CXX) $(CXXFLAGS) $^ -o ea_$@ $(LDFLAGS)

non_iid: non_iid_main.o	
	$(CXX) $(CXXFLAGS) $^ -o ea_$@ $(LDFLAGS)

restart: restart_main.o
	$(CXX) $(CXXFLAGS) $^ -o ea_$@ $(LDFLAGS)

conditioning: conditioning_main.o
	$(CXX) $(CXXFLAGS) $^ -o ea_$@ $(LDFLAGS)

transpose: transpose_main.o
	$(CXX) $(CXXFLAGS) $^ -o ea_$@ $(LDFLAGS)

######


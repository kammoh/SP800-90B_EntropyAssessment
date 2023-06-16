ARCH ?= $(shell uname -m)
OS   ?= $(shell uname -s)

CXXFLAGS = -std=c++11 -O3 -mtune=native

JSONCPP_CFLAGS ?= $(shell pkg-config --cflags jsoncpp)
JSONCPP_LDFLAGS ?= $(shell pkg-config --libs jsoncpp)
CXXFLAGS += $(JSONCPP_CFLAGS)
LDFLAGS += $(JSONCPP_LDFLAGS)

DIVSUFSORT_CFLAGS  ?= $(shell pkg-config --cflags libdivsufsort)
DIVSUFSORT_LDFLAGS ?= $(shell pkg-config --libs libdivsufsort)
CXXFLAGS += $(DIVSUFSORT_CFLAGS)
LDFLAGS  += $(DIVSUFSORT_LDFLAGS)

MPFR_CFLAGS  ?= $(shell pkg-config --cflags mpfr)
MPFR_LDFLAGS ?= $(shell pkg-config --libs mpfr)

GMP_CFLAGS  ?= $(shell pkg-config --cflags gmp)
GMP_LDFLAGS ?= $(shell pkg-config --libs gmp)

ifeq ($(OS), Darwin)
OPENSSL_PREFIX  ?= /opt/homebrew/opt/openssl@1.1/
CXXFLAGS += -Xclang -fopenmp -Wno-deprecated-declarations
LDFLAGS  += -lomp
ifeq ($(ARCH),x86)
CXXFLAGS += -march=native
endif
else
OPENSSL_PREFIX  ?= /usr/local
CXXFLAGS += -fopenmp -march=native
LDFLAGS  += -fopenmp
endif

OPENSSL_CFLAGS  ?= -I$(OPENSSL_PREFIX)/include
OPENSSL_LDFLAGS ?= -L$(OPENSSL_PREFIX)/lib -lcrypto
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

######
# Main operations
######

all: iid non_iid restart conditioning transpose

clean:
	rm -f ea_iid ea_non_iid ea_restart ea_conditioning ea_transpose selftest/*.res

iid: iid_main.o
iid_main.o: iid_main.cpp
	$(CXX) $(CXXFLAGS) iid_main.cpp -o ea_iid $(LDFLAGS)
	
non_iid: non_iid_main.o	
non_iid_main.o: non_iid_main.cpp
	$(CXX) $(CXXFLAGS) non_iid_main.cpp -o ea_non_iid $(LDFLAGS)

restart: restart_main.o
restart_main.o: restart_main.cpp
	$(CXX) $(CXXFLAGS) restart_main.cpp -o ea_restart $(LDFLAGS)

conditioning: conditioning_main.o
conditioning_main.o: conditioning_main.cpp
	$(CXX) $(COND_CXXFLAGS) conditioning_main.cpp -o ea_conditioning $(COND_LDFLAGS)

transpose: transpose_main.o
transpose_main.o: transpose_main.cpp
	$(CXX) $(CXXFLAGS) transpose_main.cpp -o ea_transpose $(LDFLAGS)

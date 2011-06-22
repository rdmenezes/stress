
SRC_HOME=../../../src
CFLAGS=-I$(SRC_HOME) -I../../../lib -I. 
LFLAGS=-L../../../lib -lstress -lboost_system -lboost_iostreams -lcrypto


all: parseabnf


parseabnf: Parser.o $(SRC_HOME)/ABNFParser.o  $(SRC_HOME)/driver.o  $(SRC_HOME)/scanner.o $(SRC_HOME)/parser.o $(SRC_HOME)/symbol.o ../../../lib/libstress.a
	g++ $(LFLAGS) -o "$@" $^
	rm *.o

Parser.o: Parser.cc
	g++ $(CFLAGS) $(LFLAGS) -c $<




clean:
	-rm parseabnf
	
	

build-clean: clean all




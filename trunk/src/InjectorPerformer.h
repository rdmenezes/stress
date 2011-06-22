/* 
 * File:   InjectorPerformer.h
 * Author: Lu
 *
 * Created on 26 aprile 2010, 16.54
 */

#ifndef _INJECTORPERFORMER_H
#define	_INJECTORPERFORMER_H

#include "composite.h"
#include "composite-factory.h"


class InjectorPerformer {

public:
    InjectorPerformer();
    InjectorPerformer(bool strL, bool hexL, bool decL, bool binL);
    InjectorPerformer(const InjectorPerformer& orig);
    virtual ~InjectorPerformer();

    Composite* inject(Leaf* leaf);
    Composite* inject(StringLeaf* leaf);
    Composite* inject(HexLeaf* leaf);
    Composite* inject(DecLeaf* leaf);
    Composite* inject(BinLeaf* leaf);
    Composite* inject(Composite* leaf);
    
private:
    bool injectStringLeaves;
    bool injectHexLeaves;
    bool injectDecLeaves;
    bool injectBinLeaves;
    int anomalyCounter;
    int orCounter;

    Composite* injectStringLeaf(StringLeaf* orig);
    Composite* stringInjectionNONASCII(StringLeaf* orig, CompositeFactory* cf);
    Composite* stringInjectionMIDDLETERM(StringLeaf* orig, CompositeFactory* cf, std::string term);
    Composite* stringInjectionVERYLONG(StringLeaf* orig, CompositeFactory* cf, int l);
    Composite* stringInjectionRANDOMFUZZ(StringLeaf* orig, CompositeFactory* cf);
    Composite* stringInjectionNULLSTRING(StringLeaf* orig, CompositeFactory* cf);

    std::string generateAnomalyName(Composite* orig);
    std::string trim (Composite* orig);
    std::string addQuote(std::string s);
};

#endif	/* _INJECTORPERFORMER_H */


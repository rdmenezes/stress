/* 
 * File:   InjectorPerformer.cc
 * Author: Lu
 * 
 * Created on 26 aprile 2010, 16.54
 */

#include "InjectorPerformer.h"
#include <leaf.h>
#include <string-leaf.h>
#include <bin-leaf.h>
#include <hex-leaf.h>
#include <dec-leaf.h>
#include <iostream>
#include <sstream>
#include <string>
#include <stdlib.h>

#define VERYLONG_ 512

InjectorPerformer::InjectorPerformer() {
    anomalyCounter = 0;
    orCounter = 0;
}

InjectorPerformer::InjectorPerformer(bool strL, bool hexL, bool decL, bool binL) {
    injectStringLeaves = strL;
    injectHexLeaves = hexL;
    injectDecLeaves = decL;
    injectBinLeaves = binL;
    anomalyCounter = 0;
    orCounter = 0;
    srand(time(NULL));
}

InjectorPerformer::InjectorPerformer(const InjectorPerformer& orig) {
}

InjectorPerformer::~InjectorPerformer() {
}

Composite* InjectorPerformer::inject(Composite* comp) {

    Composite* c;

    if (dynamic_cast<StringLeaf*> (comp))
        c = inject(dynamic_cast<StringLeaf*> (comp));
    else if (dynamic_cast<HexLeaf*> (comp))
        c = inject(dynamic_cast<HexLeaf*> (comp));
    else if (dynamic_cast<DecLeaf*> (comp))
        c = inject(dynamic_cast<DecLeaf*> (comp));
    else if (dynamic_cast<BinLeaf*> (comp))
        c = inject(dynamic_cast<BinLeaf*> (comp));
    else
        c = comp->clone();

    return c;
}

Composite* InjectorPerformer::inject(Leaf* leaf) {
    std::cout << "Injecting Leaf" << leaf->getName() << std::endl;
    return (Composite*) leaf->clone();
}

Composite* InjectorPerformer::inject(StringLeaf* leaf) {


    if (injectStringLeaves) {
        std::cout << "Injecting StringLeaf" << leaf->getName() << std::endl;
        return injectStringLeaf(leaf);
    } else
        return (Composite*) leaf->clone();
}

Composite* InjectorPerformer::inject(HexLeaf* leaf) {
    std::cout << "Injecting HexLeaf" << leaf->getName() << std::endl;
    if (injectHexLeaves) {
        return (Composite*) leaf->clone(); //TODO
    } else
        return (Composite*) leaf->clone();

}

Composite* InjectorPerformer::inject(DecLeaf* leaf) {
    std::cout << "Injecting DecLeaf" << leaf->getName() << std::endl;
    if (injectDecLeaves) {
        return (Composite*) leaf->clone(); //TODO
    } else
        return (Composite*) leaf->clone();
}

Composite* InjectorPerformer::inject(BinLeaf* leaf) {
    std::cout << "Injecting BinLeaf" << leaf->getName() << std::endl;
    if (injectBinLeaves) {
        return (Composite*) leaf->clone(); //TODO
    } else
        return (Composite*) leaf->clone();
}

Composite* InjectorPerformer::injectStringLeaf(StringLeaf* orig) {
	if(trim(orig).size() == 0)
		return orig;
    CompositeFactory* cfact = new CompositeFactory();
    std::ostringstream ooss(std::ostringstream::out);
    ooss << "or" << orCounter;

    Composite* orc = cfact->getOrNode(ooss.str());
    orCounter++;

    (*orc) << (orig->clone());


    (*orc) << stringInjectionMIDDLETERM(orig, cfact, std::string("%x00"));
    (*orc) << stringInjectionMIDDLETERM(orig, cfact, std::string("%x0a"));
    (*orc) << stringInjectionMIDDLETERM(orig, cfact, std::string("%x0d"));
    (*orc) << stringInjectionVERYLONG(orig, cfact, VERYLONG_);
    (*orc) << stringInjectionNONASCII(orig, cfact);
    (*orc) << stringInjectionRANDOMFUZZ(orig, cfact);
    (*orc) << stringInjectionNULLSTRING(orig, cfact);

    delete cfact;
    return orc;

}

Composite* InjectorPerformer::stringInjectionNONASCII(StringLeaf* orig, CompositeFactory* cf) {
    Composite * anomaly = cf->getNode(generateAnomalyName(orig));

    std::string origName = trim(orig);

    std::ostringstream ooss(std::ostringstream::out);

    ooss << "%x";
    for (int i = 0; i < origName.size(); i++)
        ooss << std::hex << ((int) (128 + rand() % 128));

    (*anomaly) << (cf->getHexNode(ooss.str()));

    return anomaly;

}

Composite* InjectorPerformer::stringInjectionMIDDLETERM(StringLeaf* orig, CompositeFactory* cf, std::string term) {

    Composite * anomaly = cf->getNode(generateAnomalyName(orig));
    std::string origName = trim(orig);
	int insertPoint = 0;
	if(origName.size()>1)
	    insertPoint = 1 + (rand() % (origName.size() - 1));
	else if(origName.size()==1)
		insertPoint = 1;
	else{ 
		(*anomaly) << (cf->getStringNode(addQuote(origName)));
		return anomaly;
	}
    std::cout << "Insert Point is " << insertPoint << " out of " << origName.size() << std::endl;

    (*anomaly) << (cf->getStringNode(addQuote(origName.substr(0, insertPoint))));
    (*anomaly) << (cf->getHexNode(term));
    (*anomaly) << (cf->getStringNode(addQuote(origName.substr(insertPoint))));

    return anomaly;
}

Composite* InjectorPerformer::stringInjectionVERYLONG(StringLeaf* orig, CompositeFactory* cf, int lenght) {
    Composite * anomaly = cf->getNode(generateAnomalyName(orig));

    std::string origName = trim(orig);

    std::ostringstream ooss(std::ostringstream::out);

    ooss << origName;

    while (ooss.str().size() < lenght)
        ooss << origName;

    (*anomaly) << (cf->getStringNode(addQuote(ooss.str())));

    return anomaly;
}

Composite* InjectorPerformer::stringInjectionRANDOMFUZZ(StringLeaf* orig, CompositeFactory* cf) {
    Composite * anomaly = cf->getNode(generateAnomalyName(orig));

    std::string origName = trim(orig);

    std::ostringstream ooss(std::ostringstream::out);

    ooss << "%x";
    for (int i = 0; i < origName.size(); i++)
        ooss << std::hex << ((int) (rand() % 128));

    (*anomaly) << (cf->getHexNode(ooss.str()));

    return anomaly;

}

Composite* InjectorPerformer::stringInjectionNULLSTRING(StringLeaf* orig, CompositeFactory* cf) {

    Composite * anomaly = cf->getNode(generateAnomalyName(orig));

    (*anomaly) << (cf->getStringNode(addQuote(std::string(""))));
    return anomaly;
}

std::string InjectorPerformer::generateAnomalyName(Composite* orig) {

    std::ostringstream ostr(std::ostringstream::out);

    std::string origName = trim(orig);

    ostr << "anomaly";
    ostr << anomalyCounter << "";
    //ostr << origName;

    anomalyCounter++;
    return ostr.str();
}

std::string InjectorPerformer::trim(Composite* orig) {
    std::string origName = orig->getName();
    origName = origName.erase(0, (origName.find_first_of("\"") + 1));
    origName = origName.erase(origName.find_last_of("\\"));
    return origName;
}

std::string InjectorPerformer::addQuote(std::string s) {
    std::ostringstream ooss(std::ostringstream::out);
    ooss << "\\\"" << s << "\\\"";
    return ooss.str();
}

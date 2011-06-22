#ifndef _ACTION_FACTORY_H
#define _ACTION_FACTORY_H

#include<leaf.h>
#include<action.h>
#include<composite.h>
#include<command-composite.h>
#include<or-composite.h>
#include<repeat-composite.h>
#include<map>
#include<command.h>
#include<include-actions.h>

class ActionFactory{
	public:
		~ActionFactory();
		static ActionFactory* getInstance();

		Action* getAction(RepeatComposite*);
		Action* getAction(OrComposite*);
		Action* getAction(Composite*);
		Action* getAction(Leaf*);

		uint64_t getNextInjectionId();

		void registerCommand(std::string, Command*);
		void clearCommands();
	protected:
		ActionFactory();
	private:
		static ActionFactory* _instance;
		
		Action* getActionFromFirstSon(CommandComposite*);
		Action* getActionFromFirstSon(Composite*);

		std::map<std::string, Command*> commands;
		uint64_t next_injection_id;
};

#endif

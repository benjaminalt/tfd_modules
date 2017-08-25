/*
 * ExpectedFutureEffects.h
 *
 *  Created on: Aug 25, 2017
 *      Author: andreas
 */

#ifndef SRC_EXPECTEDFUTUREEFFECTS_H_
#define SRC_EXPECTEDFUTUREEFFECTS_H_

#include <boost/shared_ptr.hpp>
#include <continual_planning_executive/predicate.h>
#include <map>

using std::map;
using std::string;

class ExpectedFutureEvent
{
public:
	typedef boost::shared_ptr<ExpectedFutureEvent> Ptr;
	typedef boost::shared_ptr<ExpectedFutureEvent const> ConstPtr;
	ExpectedFutureEvent(double time);
	virtual ~ExpectedFutureEvent();

	void clear();
	void setBooleanFluent(const Predicate& p, bool value);
	void setObjectFluent(const Predicate& p, const string& value);
	void setNumericalFluent(const Predicate& p, double value);
	/**
	 * @param time in seconds from now
	 */
	void setTime(double time);
	double getTime() const;

private:
	double time;
	map<Predicate, bool> boolean_fluents;
	map<Predicate, double> numerical_fluents;
	map<Predicate, string> object_fluents;
};

#endif /* SRC_EXPECTEDFUTUREEFFECTS_H_ */

#include "best_first_search.h"

#include "globals.h"
#include "heuristic.h"
#include "successor_generator.h"
#include "plannerParameters.h"
#include <time.h>
#include <iomanip>

#include <cassert>
using namespace std;

OpenListInfo::OpenListInfo(Heuristic *heur, bool only_pref)
{
    heuristic = heur;
    only_preferred_operators = only_pref;
    priority = 0;
}

BestFirstSearchEngine::BestFirstSearchEngine(QueueManagementMode _mode) :
    current_state(*g_initial_state), currentQueueIndex(-1), mode(_mode)
{
    current_predecessor = 0;
    current_operator = 0;
    start_time = time(NULL);
    bestMakespan = HUGE_VAL;
    bestSumOfGoals = HUGE_VAL;
}

BestFirstSearchEngine::~BestFirstSearchEngine()
{
}

void BestFirstSearchEngine::add_heuristic(Heuristic *heuristic,
        bool use_estimates, bool use_preferred_operators)
{
    assert(use_estimates || use_preferred_operators);
    heuristics.push_back(heuristic);
    best_heuristic_values.push_back(-1);
    best_states.push_back(NULL);
    if(use_estimates) {
        open_lists.push_back(OpenListInfo(heuristic, false));
    }
    if(use_preferred_operators) {
        preferred_operator_heuristics.push_back(heuristic);
        open_lists.push_back(OpenListInfo(heuristic, true));
    }
}

void BestFirstSearchEngine::initialize()
{
    assert(!open_lists.empty());
}

void BestFirstSearchEngine::statistics(time_t & current_time) const
{
    cout << endl;
    cout << "Search Time: " << (current_time - start_time) << " sec." << endl;
    cout << "Expanded Nodes: " << closed_list.size() << " state(s)." << endl;
    search_statistics.dump(closed_list.size());
    cout << "OpenList sizes:";
    for(unsigned int i = 0; i < open_lists.size(); ++i) {
        cout << " " << open_lists[i].open.size();
    }
    cout << endl;
    cout << "Best heuristic value: " << best_heuristic_values[0] << endl << endl;
    //    cout << "Best state:" << endl;
    //    const TimeStampedState &state = *best_states[0];
    //    if(&state) {
    //        dump_plan_prefix_for__state(state);
    //        best_states[0]->dump();
    //    }
    //    cout << endl;
}

void BestFirstSearchEngine::dump_transition() const
{
    cout << endl;
    if(current_predecessor != 0) {
        cout << "DEBUG: In step(), current predecessor is: " << endl;
        current_predecessor->dump();
    }
    cout << "DEBUG: In step(), current operator is: ";
    if(current_operator != 0) {
        current_operator->dump();
    } else {
        cout << "No operator before initial state." << endl;
    }
    cout << "DEBUG: In step(), current state is: " << endl;
    current_state.dump();
    cout << endl;
}

void BestFirstSearchEngine::dump_everything() const
{
    dump_transition();
    cout << "DEBUG: closed List is: " << endl;
    cout << endl << endl;
    for (std::vector<OpenListInfo>::const_iterator it = open_lists.begin(); it
            != open_lists.end(); it++) {
        cout << "DEBUG: an open list is:" << endl;
        // huge dangerous hack...
        OpenListEntry const* begin = &(it->open.top());
        OpenListEntry const* end = &(it->open.top()) + it->open.size();
        for (const OpenListEntry* it2 = begin; it2 != end; it2++) {
            cout << "OpenListEntry" << endl;
            cout << "state" << endl;
            std::tr1::get<0>(*it2)->dump();
            cout << "op" << endl;
            std::tr1::get<1>(*it2)->dump();
            double h = std::tr1::get<2>(*it2);
            cout << "Value: " << h << endl;
            cout << "end OpenListEntry" << endl;
        }
    }
}

SearchEngine::status BestFirstSearchEngine::step()
{
    // Invariants:
    // - current_state is the next state for which we want to compute the heuristic.
    // - current_predecessor is a permanent pointer to the predecessor of that state.
    // - current_operator is the operator which leads to current_state from predecessor.

    bool discard = true;

    double maxTimeIncrement = 0.0;
    for(int k = 0; k < current_state.operators.size(); ++k) {
        maxTimeIncrement = max(maxTimeIncrement, current_state.operators[k].time_increment);
    }
    double makeSpan = maxTimeIncrement + current_state.timestamp;

    if (makeSpan < bestMakespan && !closed_list.contains(current_state)) {
        discard = false;
    }

    if(!discard) {
        // FIXME: What is the difference between parent_ptr and current_state?
        const TimeStampedState *parent_ptr = closed_list.insert(current_state,
                current_predecessor, current_operator);
        assert(&current_state != current_predecessor);

        for(int i = 0; i < heuristics.size(); i++) {
            heuristics[i]->evaluate(current_state);
        }
        if(!is_dead_end()) {
            if(check_progress(parent_ptr)) {
                // current_state.dump();
                report_progress();
                reward_progress();
            }
            if(check_goal())
                return SOLVED;
            generate_successors(parent_ptr);
        }
    }

    time_t current_time = time(NULL);
    static time_t last_stat_time = current_time;
    if(g_parameters.verbose && current_time - last_stat_time >= 10) {
        statistics(current_time);
        last_stat_time = current_time;
    }

    // use different timeouts depending if we found a plan or not.
    if(found_solution()) {
        if (g_parameters.timeout_if_plan_found > 0 
                && current_time - start_time > g_parameters.timeout_if_plan_found) {
            if(g_parameters.verbose)
                statistics(current_time);
            return SOLVED_TIMEOUT;
        }
    } else {
        if (g_parameters.timeout_while_no_plan_found > 0 
                && current_time - start_time > g_parameters.timeout_while_no_plan_found) {
            if(g_parameters.verbose)
                statistics(current_time);
            return FAILED_TIMEOUT;
        }
    }

    return fetch_next_state();
}

bool BestFirstSearchEngine::is_dead_end()
{
    // If a reliable heuristic reports a dead end, we trust it.
    // Otherwise, all heuristics must agree on dead-end-ness.
    int dead_end_counter = 0;
    for(int i = 0; i < heuristics.size(); i++) {
        if(heuristics[i]->is_dead_end()) {
            if(heuristics[i]->dead_ends_are_reliable())
                return true;
            else
                dead_end_counter++;
        }
    }
    return dead_end_counter == heuristics.size();
}

bool BestFirstSearchEngine::check_goal()
{
    // Any heuristic reports 0 iff this is a goal state, so we can
    // pick an arbitrary one.
    Heuristic *heur = open_lists[0].heuristic;
    if(!heur->is_dead_end() && heur->evaluate(current_state) == 0) {
        if(current_state.operators.size() > 0) {
            return false;
        }

        if(!current_state.satisfies(g_goal)) {  // will assert...
            dump_everything();
        }
        assert(current_state.operators.empty() && current_state.satisfies(g_goal));

        // We actually need this silly !heur->is_dead_end() check because
        // this state *might* be considered a non-dead end by the
        // overall search even though heur considers it a dead end
        // (e.g. if heur is the CG heuristic, but the FF heuristic is
        // also computed and doesn't consider this state a dead end.
        // If heur considers the state a dead end, it cannot be a goal
        // state (heur will not be *that* stupid). We may not call
        // get_heuristic() in such cases because it will barf.
        Plan plan;
        PlanTrace path;
        closed_list.trace_path(current_state, plan, path);
        set_plan(plan);
        set_path(path);
        return true;
    } else {
        return false;
    }
}

void BestFirstSearchEngine::dump_plan_prefix_for_current_state() const
{
    dump_plan_prefix_for__state(current_state);
}

void BestFirstSearchEngine::dump_plan_prefix_for__state(const TimeStampedState &state) const
{
    Plan plan;
    PlanTrace path;
    closed_list.trace_path(state, plan, path);
    for(int i = 0; i < plan.size(); i++) {
        const PlanStep& step = plan[i];
        cout << step.start_time << ": " << "(" << step.op->get_name() << ")"
            << " [" << step.duration << "]" << endl;
    }
}

bool BestFirstSearchEngine::check_progress(const TimeStampedState* state)
{
    bool progress = false;
    for(int i = 0; i < heuristics.size(); i++) {
        if(heuristics[i]->is_dead_end())
            continue;
        double h = heuristics[i]->get_heuristic();
        double &best_h = best_heuristic_values[i];
        if(best_h == -1 || h < best_h) {
            best_h = h;
            best_states[i] = state;
            progress = true;
        }
    }
    return progress;
}

void BestFirstSearchEngine::report_progress()
{
    cout << "Best heuristic value: ";
    for(int i = 0; i < heuristics.size(); i++) {
        cout << best_heuristic_values[i];
        if(i != heuristics.size() - 1)
            cout << "/";
    }
    cout << " [expanded " << closed_list.size() << " state(s)]" << endl;
}

void BestFirstSearchEngine::reward_progress()
{
    // Boost the "preferred operator" open lists somewhat whenever
    // progress is made. This used to be used in multi-heuristic mode
    // only, but it is also useful in single-heuristic mode, at least
    // in Schedule.
    //
    // Test the impact of this, and find a better way of rewarding
    // successful exploration. For example, reward only the open queue
    // from which the good state was extracted and/or the open queues
    // for the heuristic for which a new best value was found.

    for(int i = 0; i < open_lists.size(); i++)
        if(open_lists[i].only_preferred_operators)
            open_lists[i].priority -= 1000;
}

bool tssKnown2(ThirdClosedList& scl,
        const TimedSymbolicStates& timedSymbolicStates)
{
    assert(timedSymbolicStates.size() > 0);
    bool ret = true;
    for (int i = 0; i < timedSymbolicStates.size(); ++i) {
        if (scl.count(timedSymbolicStates[i].first) > 0) {
            double currentBestMakespan = scl[timedSymbolicStates[i].first];
            if (timedSymbolicStates[i].second + EPSILON < currentBestMakespan) {
                ret = false;
                scl[timedSymbolicStates[i].first]
                    = timedSymbolicStates[i].second;
            }
        } else {
            ret = false;
            scl[timedSymbolicStates[i].first] = timedSymbolicStates[i].second;
        }
    }
    return ret;
}

void BestFirstSearchEngine::generate_successors(const TimeStampedState *parent_ptr)
{
    vector<const Operator *> all_operators;
    g_successor_generator->generate_applicable_ops(*parent_ptr, all_operators);

    vector<const Operator *> preferred_operators;
    for(int i = 0; i < preferred_operator_heuristics.size(); i++) {
        Heuristic *heur = preferred_operator_heuristics[i];
        if(!heur->is_dead_end()) {
            heur->get_preferred_operators(preferred_operators);
        }
    }

    // HACK!?!?! Entferne pref_ops aus normaler liste
    for(int k = 0; k < preferred_operators.size(); ++k) {
        for(int l = 0; l < all_operators.size(); ++l) {
            if(all_operators[l] == preferred_operators[k]) {
                all_operators[l] = all_operators[all_operators.size() - 1];
                all_operators.pop_back();
                break;
            }
        }
    }

    double parentG, parentH, parentF;
    parentG = getG(parent_ptr, parent_ptr, NULL);

    for(int i = 0; i < open_lists.size(); i++) {
        Heuristic *heur = open_lists[i].heuristic;
        parentH = heur->evaluate(*parent_ptr);
        if (parentH == -1) {
            assert(false);
            return;
        }
        parentF = parentG + parentH;

        double childG, childH, childF;

        OpenList &open = open_lists[i].open;
        vector<const Operator *> & ops =
            open_lists[i].only_preferred_operators ? preferred_operators : all_operators;

        for(int j = 0; j < ops.size(); j++) {
            assert(ops[j]->get_name().compare("wait") != 0);
            double maxTimeIncrement = 0.0;
            for(int k = 0; k < parent_ptr->operators.size(); ++k) {
                maxTimeIncrement = max(maxTimeIncrement, parent_ptr->operators[k].time_increment);
            }
            double duration = ops[j]->get_duration(parent_ptr, 1);
            maxTimeIncrement = max(maxTimeIncrement, duration);
            double makeSpan = maxTimeIncrement + parent_ptr->timestamp;
            TimedSymbolicStates timedSymbolicStates;
            // FIXME TODO: This should be true for allow_relaxed?
            if (ops[j]->is_applicable(*parent_ptr, timedSymbolicStates, false) &&
                    makeSpan < bestMakespan &&
                    (!g_parameters.use_tss_known || !tssKnown2(tcl,timedSymbolicStates))   // use_tss_known => !tssKnow2
               ) {
                TimeStampedState tss = TimeStampedState(*parent_ptr, *ops[j]);
                if(g_parameters.lazy_evaluation) {
                    childH = 42.0;   // set something != -1, this is NOT used below
                } else {
                    childH = heur->evaluate(tss);
                }
                if (childH == -1) {
                    continue;
                }

                childG = getG(&tss, parent_ptr, ops[j]);
                childF = childG + childH;

                search_statistics.countChild(parentG, childG, parentF, childF);

                double priority = g_parameters.lazy_evaluation ? parentF : childF;
                open.push(std::tr1::make_tuple(parent_ptr, ops[j], priority));
            }
        }
        TimeStampedState tss = parent_ptr->let_time_pass(false);
        if(g_parameters.lazy_evaluation) {
            childH = 42.0;   // set something != -1, this is NOT used below
        } else {
            childH = heur->evaluate(tss);
        }
        if (childH == -1) {
            return;
        }

        childG = getG(&tss, parent_ptr, NULL);
        childF = childH + childG;

        search_statistics.countChild(parentG, childG, parentF, childF);
        search_statistics.finishExpansion();

        double priority = g_parameters.lazy_evaluation ? parentF : childF;
        open.push(std::tr1::make_tuple(parent_ptr, g_let_time_pass, priority));
    }
}

enum SearchEngine::status BestFirstSearchEngine::fetch_next_state()
{
    OpenListInfo *open_info = select_open_queue();
    if(!open_info) {
        if(found_at_least_one_solution()) {
            cout << "Completely explored state space -- best plan found!" << endl;
            return SOLVED;
        }
        
        if(g_parameters.verbose) {
            time_t current_time = time(NULL);
            statistics(current_time);
        }
        cout << "Completely explored state space -- no solution!" << endl;
        return FAILED;
    }

    std::tr1::tuple<const TimeStampedState *, const Operator *, double> next =
        open_info->open.top();
    open_info->open.pop();

    // tentative new current_predecessor and current_operator
    // We need to recheck operator applicability in case a relaxed op (relaxed module calls)
    // was inserted in the open queue
    const TimeStampedState* state = std::tr1::get<0>(next);
    const Operator* op = std::tr1::get<1>(next);

    TimedSymbolicStates tss;
    if (op != g_let_time_pass && !op->is_applicable(*state, tss, false)) {
        return fetch_next_state();
    }
    open_info->priority++;

    current_predecessor = std::tr1::get<0>(next);
    current_operator = std::tr1::get<1>(next);

    if(current_operator == g_let_time_pass) {
        // do not apply an operator but rather let some time pass until
        // next scheduled happening
        current_state = current_predecessor->let_time_pass();
    } else {
        assert(current_operator->get_name().compare("wait") != 0);
        current_state = TimeStampedState(*current_predecessor, *current_operator);
    }
    assert(&current_state != current_predecessor);
    return IN_PROGRESS;
}

OpenListInfo *BestFirstSearchEngine::select_open_queue()
{
    OpenListInfo *best = 0;

    switch(mode) {
        case PRIORITY_BASED:
            for(int i = 0; i < open_lists.size(); i++) {
                if(!open_lists[i].open.empty() && (best == 0 || open_lists[i].priority < best->priority))
                    best = &open_lists[i];
            }
            break;
        case ROUND_ROBIN:
            for(int i = 0; i < open_lists.size(); i++) {
                currentQueueIndex = (currentQueueIndex + 1) % open_lists.size();
                if(!open_lists[currentQueueIndex].open.empty()) {
                    best = &open_lists[currentQueueIndex];
                    break;
                }
            }
            break;
    }

    return best;
}

double BestFirstSearchEngine::getGc(const TimeStampedState *state) const
{
    return closed_list.getCostOfPath(*state);
}

double BestFirstSearchEngine::getGc(const TimeStampedState *state,
        const Operator *op) const
{
    double opCost = 0.0;
    if (op && op != g_let_time_pass) {
        opCost += op->get_duration(state);
    }
    return getGc(state) + opCost;
}

double BestFirstSearchEngine::getGm(const TimeStampedState *state) const
{
    double longestActionDuration = 0.0;
    for (int i = 0; i < state->operators.size(); ++i) {
        const ScheduledOperator* op = &state->operators[i];
        double duration = 0.0;
        if (op && op != g_let_time_pass) {
            duration = op->origin->get_duration(state);  // FIXME use origin
        }
        if (duration > longestActionDuration) {
            longestActionDuration = duration;
        }
    }
    return state->timestamp + longestActionDuration;
}

double BestFirstSearchEngine::getGt(const TimeStampedState *state) const
{
    return state->timestamp;
}

/**
 * If mode is cost or weighted a parent_ptr and op have to be given.
 *
 * \param [in] state_ptr the state to compute G for
 * \param [in] closed_ptr should be a closed node that op could be applied to, if state is not closed (i.e. a child)
 */
double BestFirstSearchEngine::getG(const TimeStampedState* state_ptr, 
        const TimeStampedState* closed_ptr, const Operator* op) const
{
    double g = HUGE_VAL;
    switch(g_parameters.g_values) {
        case PlannerParameters::GTimestamp:
            g = getGt(state_ptr);
            break;
        case PlannerParameters::GCost:
            if(op == NULL)
                g = getGc(closed_ptr);
            else
                g = getGc(closed_ptr, op);
            break;
        case PlannerParameters::GMakespan:
            g = getGm(state_ptr);
            break;
        case PlannerParameters::GWeighted:
            if(op == NULL)
                g = g_parameters.g_weight * getGm(state_ptr) 
                    + (1.0 - g_parameters.g_weight) * getGc(closed_ptr);
            else
                g = g_parameters.g_weight * getGm(state_ptr) 
                    + (1.0 - g_parameters.g_weight) * getGc(closed_ptr, op);
            break;
        default:
            assert(false);
    }
    return g;
}


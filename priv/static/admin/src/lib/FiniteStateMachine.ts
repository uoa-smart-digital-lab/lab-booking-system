/*------------------------------------------------------------------------------------------------------
  A Finite State Machine (FSM).

  Author: Dr. Roy C. Davies
  Created: June 2023
  Contact: roy.c.davies@ieee.org
------------------------------------------------------------------------------------------------------*/

// ----------------------------------------------------------------------------------------------------
// A Transition contains a new state and a possible action (function)
// ----------------------------------------------------------------------------------------------------
class Transition<S> {
    newState : S;
    action : (args : {}) => void;
  
    constructor (newState : S, action : (args : {}) => void) {
      this.newState = newState;
      this.action = action;
    }
}
// ----------------------------------------------------------------------------------------------------



// ----------------------------------------------------------------------------------------------------
// An Automation contains Transitions which are held in a structure such that when the step fuction is
// called, the next step is chosen.
// ----------------------------------------------------------------------------------------------------
export default class Automation<S, E> {
    // The current State
    currentState : S;
    // The Transitions
    transitions : Map<string, Transition<S>>;
    // The function to create the key
    key : ( currentState : S, triggerEvent : E ) => string;
    // The Wildcard character (usually '*')
    wildcard : S;

    // ------------------------------------------------------------------------------------------------
    // Construct the Automation and set the initial state.
    // ------------------------------------------------------------------------------------------------
    constructor (startState : S, createKey : ( currentState : S, triggerEvent : E ) => string, wildcard : S) {
        this.currentState = startState;
        this.wildcard = wildcard;
        this.key = createKey;
        this.transitions = new Map();
    }
    // ------------------------------------------------------------------------------------------------



    // ------------------------------------------------------------------------------------------------
    // Add a new Transition to the Automation.
    // Currentstate is the currentstate at which the triggerEvent will cause the Transition to occur.
    // If it occurs, it moves to the newState, and calls the action function as it does it.
    // ------------------------------------------------------------------------------------------------
    add_transition(currentState : S, triggerEvent : E, newState : S, action : (args : {}) => void)
    {
        // Create the key
        let theKey : string = this.key(currentState, triggerEvent);
        // Add the transition
        this.transitions.set(theKey, new Transition<S>(newState, action));
    };
    // ------------------------------------------------------------------------------------------------



    // ------------------------------------------------------------------------------------------------
    // Given the current State, and an event, check to see if a Transition is to occur, and if so,
    // do the action
    // ------------------------------------------------------------------------------------------------
    step(triggerEvent : E, args : object = {})
    {
        // Create the key
        let theKey = this.key(this.currentState, triggerEvent);
        // Find the relevant transition
        let aTransition = this.transitions.get(theKey);
        // Create the wildcard key
        let wildcardKey = this.key(this.wildcard, triggerEvent);
        // Find the wildcard transition
        let wildcardTransition = this.transitions.get(wildcardKey);

        // If one exists
        if (wildcardTransition)
        {
            console.log(this.wildcard + " + " + triggerEvent + " -> " + wildcardTransition.newState);

            // Set the new state if the new state is not the wildcard, in which case leave it the same
            if (wildcardTransition.newState !== this.wildcard)
            {
                this.currentState = wildcardTransition.newState;
            }
            // Do the actions passing in the arguments from the calling function
            wildcardTransition.action(args);
        }
        else if (aTransition)
        {
            console.log(this.currentState + " + " + triggerEvent + " -> " + aTransition.newState);

            // Set the new state if the new state is not the wildcard, in which case leave it the same
            if (aTransition.newState !== this.wildcard)
            {
                this.currentState = aTransition.newState;
            }
            // Do the actions passing in the arguments from the calling function
            aTransition.action(args);
        } 
        else
        {
            console.log(this.currentState + " + " + triggerEvent);

            // Regiter there was an error.
            console.log("Error Transitioning.");
        }
    }
}
// ----------------------------------------------------------------------------------------------------

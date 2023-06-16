// import logo from './logo.svg';
import React, { useState, useEffect } from 'react';
import './App.css';
import 'semantic-ui-css/semantic.min.css';
import { Segment, Header, Icon, Dropdown, Divider } from 'semantic-ui-react'
import GraphQLTable from './GraphQLTable';
import Login from './Login';
import {
  gql
} from "@apollo/client";

// ----------------------------------------------------------------------------------------------------
// Get values in the query
// ----------------------------------------------------------------------------------------------------
const getQuery = () => {
    if (typeof window !== 'undefined') {
      return new URLSearchParams(window.location.search);
    }
    return new URLSearchParams();
};
const getQueryStringVal = (key) => {
    let query = getQuery();
    let returnValue = query.get(key);
    window.history.pushState({}, document.title, window.location.pathname);
    return returnValue;
};
// ----------------------------------------------------------------------------------------------------

// ----------------------------------------------------------------------------------------------------
// User table details
// ----------------------------------------------------------------------------------------------------
const user_details = 
{
    title: "All People",
    description: "View and edit all people", 

    usertype: ["ADMIN", "POWERUSER", "USER"],

    columns: [
        {title: "UPI", width: 3, name: "upi", type: "string", editable: false, index: true},
        {title: "Name", width: 3, name: "name", type: "string", editable: true, index: false}, 
        {title: "Password", width: 3, name: "password", type: "password", editable: true, nocol: true, index: false}, 
        {title: "Status", width: 3, name: "status", type: "enum", enum: "usertype", editable: true, index: false},
        {title: "Tokens", width: 3, name: "tokens", type: "number", editable: false, index: false},
        {title: "Details", width: 3, name: "details", type: "json", editable: false, index: false},
        {title: "Inductions", width: 3, name: "inductions", type: "table", table: ["inductions", "name"], editable: true, index: true}
    ],

    queries: {
        main: gql`query personAll { personAll { upi name password status tokens details inductions { name }}}`,
        update: gql`mutation personUpdate ($upi:String!, $name:String, $password:String, $details:Json, $status:Usertype)
        {
          personUpdate(upi:$upi, name:$name, password:$password, details:$details, status:$status) {
            upi
          }
        }`,
        create: gql`mutation personCreate ($upi:String!, $name:String!, $password:String!, $details:Json!, $status:Usertype! )
        {
          personCreate(upi:$upi, name:$name, password:$password, details:$details, status:$status) {
            upi
          }
        }`,
        delete: gql`mutation personDelete ($upi:String!)
        {
          personDelete (upi:$upi) {
            upi
          }
        }`
    },

    subqueries: {
        inductions: gql`query { itemAll { name } }`
    }
};
// ----------------------------------------------------------------------------------------------------



// ----------------------------------------------------------------------------------------------------
// Item table details
// ----------------------------------------------------------------------------------------------------
const item_details = 
{
    title: "All Items",
    description: "View and edit all bookable items", 

    accesstype: ["FREE", "INDUCTION", "SUPERVISED"],

    columns: [
        {title: "Name", width: 3, name: "name", type: "string", editable: false, index: true}, 
        {title: "Image", width: 3, name: "image", type: "string", editable: true, index: false}, 
        {title: "URL", width: 3, name: "url", type: "url", editable: true, index: false},
        {title: "Cost", width: 1, name: "cost", type: "number", editable: true, index: false},
        {title: "Bookable", width: 1, name: "bookable", type: "boolean", editable: true, index: false},
        {title: "Access", width: 2, name: "access", type: "enum", enum: "accesstype", editable: true, index: false},
        {title: "Details", width: 1, name: "details", type: "json", editable: false, index: false}
    ],

    queries: {
        main: gql`query itemAll { itemAll { name image url cost bookable access details} }`,
        update: gql`mutation itemUpdate ($name:String!, $url:String!, $image:String!, $details:Json!, $cost:Int!, $bookable:Boolean!, $access:Itemtype!)
        {
          itemUpdate(name:$name, url:$url, image:$image, details:$details, cost:$cost, bookable:$bookable, access:$access) {
            name
          }
        }`,
        create: gql`mutation itemCreate ($name:String!, $url:String!, $image:String!, $details:Json!, $cost:Int!, $bookable:Boolean!, $access:Itemtype!)
        {
          itemCreate(name:$name, url:$url, image:$image, details:$details, cost:$cost, bookable:$bookable, access:$access) {
            name
          }
        }`,
        delete: gql`mutation itemDelete ($name:String!)
        {
          itemDelete(name:$name) {
            name
          }
        }`
    }
};
// ----------------------------------------------------------------------------------------------------


// ----------------------------------------------------------------------------------------------------
// Inductions table details
// ----------------------------------------------------------------------------------------------------
const induction_details_for_person = 
{
    title: "Inductions",
    description: "View and edit inductions for a person", 

    columns: [
        {title: "UPI", width: 3, name: "upi", type: "string", editable: false, index: true}, 
        {title: "Item Name", width: 3, name: "itemName", type: "table", table: ["item", "name"], editable: true, index: false}
    ],

    queries: {
        main: gql`query personGet($upi: String!) {
            personGet (upi:$upi) { 
                upi 
                inductions { 
                    name 
                }
            }
        }`,
        create: gql`mutation personInduct ($upi:String!, $itemname:String! ) {
            personInduct (upi:$upi, itemname:$itemname) {
                upi
                inductions {
                    name
                }
            }
        }`,
        delete: gql`mutation personUninduct ($name: String!) {
            personUninduct (upi:$upi, itemname:$itemname) {
                upi
                inductions {
                    name
                }
            }
        }`
    },

    subqueries: {
        itemName: gql`query { itemAll { name } }`
    }
};
// ----------------------------------------------------------------------------------------------------



// ----------------------------------------------------------------------------------------------------
// Occupancy table details
// ----------------------------------------------------------------------------------------------------
const occupancy_details = 
{
    title: "Occupants currently in a item for a course",
    description: "View and edit all occupants", 

    columns: [
        {title: "Occupant Name", width: 3, name: "upi", type: "table", table: ["person", "upi"], editable: true, index: true}, 
        {title: "Item Name", width: 3, name: "itemName", type: "table", table: ["item", "name"], editable: true, index: true}
    ],

    queries: {   
        main: gql`query allOccupants {
            allOccupants { item { name } person { upi name } } }`,
        update: gql`mutation scanIn ($itemName: String!, $upi: String!) {
            scanIn (itemName: $itemName, upi: $upi) {
                occupants { upi } item { name } } }`,
        create: gql`mutation scanIn ($itemName: String!, $upi: String!) {
            scanIn (itemName: $itemName, upi: $upi) {
                occupants { upi } item { name } } }`,
        delete: gql`mutation scanOut ($itemName: String!, $upi: String!) {
            scanOut (itemName: $itemName, upi: $upi) {
                occupants { upi } item { name } } }`
    },

    subqueries: {
        itemName: gql`query { allItems { name } }`,
        upi: gql`query { allPeople { upi } }`
    }
};
// ----------------------------------------------------------------------------------------------------



// ----------------------------------------------------------------------------------------------------
// Participancy table details
// ----------------------------------------------------------------------------------------------------
const participancy_details = 
{
    title: "Participants currently enrolled in a course",
    description: "View and edit all particpants", 

    columns: [
        {title: "Participant Name", width: 3, name: "upi", type: "table", table: ["person", "upi"], editable: true, index: true}, 
        {title: "Course Name", width: 3, name: "courseName", type: "table", table: ["course", "name"], editable: true, index: true}
    ],

    queries: {   
        main: gql`query allParticipants {
            allParticipants { course { name } person { upi name } } }`,
        update: gql`mutation add ($courseName: String!, $upi: String!) {
            add (courseName: $courseName, upi: $upi) {
                participants { upi } course { name } } }`,
        create: gql`mutation add ($courseName: String!, $upi: String!) {
            add (courseName: $courseName, upi: $upi) {
                participants { upi } course { name } } }`,
        delete: gql`mutation scanOut ($courseName: String!, $upi: String!) {
            remove (courseName: $courseName, upi: $upi) {
                participants { upi } course { name } } }`
    },

    subqueries: {
        courseName: gql`query { allCourses { name } }`,
        upi: gql`query { allPeople { upi } }`
    }
};
// ----------------------------------------------------------------------------------------------------



// ----------------------------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------------------------
export default function App() {
    // ------------------------------------------------------------------------------------------------
    // Set up the state variables.  Use state.set("Variable Name", New Value) to set.  Whenever it
    // is called, the page is refreshed.
    // ------------------------------------------------------------------------------------------------
    const [state, setState] = useState({
		sessionid: "",
        currentState: 0,
        errorMessage: "",
        currentTitle: "Dashboard",
        states: {start: 0, main: 1, people: 2, items: 3, inductions: 5, bookings: 6, induct: 8, error: 20, done: 21},
        headings: {start: "Dashboard", main: "Dashboard", people: "People", items: "Items", inductions: "Inductions", induct: "Induct or Uninduct"},

        set: (name, value) => { setState( previousState => { return { ...previousState, [name]: value }} ); }
	});
    // ------------------------------------------------------------------------------------------------


    // ------------------------------------------------------------------------------------------------
    // Anything you want to run when something changes, and on first load.  Add variables etc to array
    // to define them as requiring a reload when they change.
    // ------------------------------------------------------------------------------------------------
    useEffect(() =>
	{
        let sessionid = getQueryStringVal("sessionid");
        if (sessionid) {
            state.set("sessionid", sessionid);
            state.set("currentState", state.states.main);
        }
	}, []);
    // ------------------------------------------------------------------------------------------------


    // ------------------------------------------------------------------------------------------------
    // ------------------------------------------------------------------------------------------------
    function Main() {
        return (
            <Segment placeholder>
            <Header icon>
              <Icon name='Question' />
              Choose one of the tables from the menu.
            </Header>
          </Segment>
        )
    }
    // ------------------------------------------------------------------------------------------------


    // ------------------------------------------------------------------------------------------------
    // ------------------------------------------------------------------------------------------------
    const MainDisplay = () => {
        switch (state.currentState) {
            case state.states.start         : return (<Login errorMessage={state.errorMessage} error={() => {state.set("errorMessage","Error logging in");}} loggedin={(result) => {state.set("sessionid", result.sessionid); state.set("currentState", state.states.main)}}/>)
            case state.states.main          : return (<Main />)
            case state.states.people        : return (<GraphQLTable sessionid={state.sessionid} details={user_details}/>)
            case state.states.items         : return (<GraphQLTable sessionid={state.sessionid} details={item_details}/>)
            case state.states.inductions    : return (<GraphQLTable sessionid={state.sessionid} details={induction_details_for_person}/>)
            // case state.states.occupants     : return (<GraphQLTable sessionid={state.sessionid} details={occupancy_details}/>)
            // case state.states.participants  : return (<GraphQLTable sessionid={state.sessionid} details={participancy_details}/>)
            case state.states.induct        : window.location = "/induct?sessionid=" + state.sessionid;
            default                         : return (<Main />)
        }
    }
    // ------------------------------------------------------------------------------------------------


    // ------------------------------------------------------------------------------------------------
    // ------------------------------------------------------------------------------------------------
    const handleItemClick = (e, {value}) => { if(value !== "divider") {state.set("currentTitle", state.headings[value]); state.set("currentState", state.states[value]);} }
    // ------------------------------------------------------------------------------------------------


    // ------------------------------------------------------------------------------------------------
    // ------------------------------------------------------------------------------------------------
    const menu_options = [
        {key: "main", text: state.headings.start, value: "main"},
        {key: "people", text: state.headings.people, value: "people"},
        {key: "items", text: state.headings.items, value: "items"},
        {key: "inductions", text: state.headings.inductions, value: "inductions"},
        // {key: "occupants", text: state.headings.occupants, value: "occupants"},
        // {key: "participants", text: state.headings.participants, value: "participants"},
        {content: (<Divider fitted />), value: "divider"},
        {key: "induct", text: state.headings.induct, value: "induct"}
    ]
    // ------------------------------------------------------------------------------------------------



    // ------------------------------------------------------------------------------------------------
    // ------------------------------------------------------------------------------------------------
    return (
        <>
            <Header textAlign="center" centered as="h2" color='blue' block>
                Admin
            </Header>
            <MainDisplay />
            <div style={{position: "fixed", top: "5px", left: "5px"}}>
                <Dropdown style={{width:"150px"}} icon ='bars' text={state.currentTitle} labeled className='icon' button options={menu_options} onChange={handleItemClick}/>
            </div>
        </>
    );
}
// ----------------------------------------------------------------------------------------------------

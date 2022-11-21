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
        {title: "Status", width: 3, name: "status", type: "enum", enum: "usertype", editable: true, index: false}
    ],

    queries: {
        main: gql`query personAll { personAll { upi, name, password, status } }`,
        update: gql`mutation personUpdate ($name: String, $status: Usertype, $upi: String!, $password: String) {
            personUpdate (name: $name, status: $status, upi: $upi, password: $password) {
                upi
            }
        }`,
        create: gql`mutation personCreate ($name: String!, $status: Usertype!, $upi: String!, $password: String!) {
            personCreate (name: $name, status: $status, upi: $upi, password: $password, details: "{}") {
                upi
            }
        }`,
        delete: gql`mutation personDelete ($upi: String!) {
            personDelete (upi: $upi) {
                upi
            }
        }`
    }
};
// ----------------------------------------------------------------------------------------------------



// ----------------------------------------------------------------------------------------------------
// Item table details
// ----------------------------------------------------------------------------------------------------
const item_details = 
{
    title: "All Items",
    description: "View and edit all items", 

    columns: [
        {title: "Name", width: 3, name: "name", type: "string", editable: false, index: true}, 
        {title: "Image", width: 3, name: "image", type: "string", editable: true, index: false}, 
        {title: "URL", width: 3, name: "url", type: "url", editable: true, index: false}
    ],

    queries: {
        main: gql`query itemAll { itemAll { name,  image, url } }`,
        update: gql`mutation itemUpdate ($url: String, $image: String, $name: String!) {
            itemUpdate (image: $image, url: $url, name: $name) {
                name
            }
        }`,
        create: gql`mutation itemCreate ($url: String!, $image: String!, $name: String!) {
            itemCreate (image: $image, url: $url, name: $name, details: "{}") {
                name
            }
        }`,
        delete: gql`mutation itemDelete ($name: String!) {
            itemDelete (name: $name) {
                name
            }
        }`
    }
};
// ----------------------------------------------------------------------------------------------------


// ----------------------------------------------------------------------------------------------------
// Course table details
// ----------------------------------------------------------------------------------------------------
const course_details = 
{
    title: "All Courses",
    description: "View and edit all courses", 

    columns: [
        {title: "Name", width: 3, name: "name", type: "string", editable: false, index: true}, 
        {title: "Canvas URL", width: 3, name: "canvasurl", type: "url", editable: true, index: false},
        {title: "Max Number Students", width: 3, name: "max", type: "number", editable: true, index: false},
        {title: "Item Name", width: 3, name: "itemName", type: "table", table: ["item", "name"], editable: true, index: false}
    ],

    queries: {
        main: gql`query allCourses { allCourses { name, canvasurl, max item { name } } }`,
        update: gql`mutation updateCourse ($canvasurl: String, $max: Int, $name: String!, $itemName: String) {
            updateCourse (canvasurl: $canvasurl, max: $max, name: $name, itemName: $itemName) {
                name
            }
        }`,
        create: gql`mutation createCourse ($canvasurl: String!, $max: Int!, $name: String!, $itemName: String!) {
            createCourse (canvasurl: $canvasurl, max: $max, name: $name, itemName: $itemName) {
                name
            }
        }`,
        delete: gql`mutation deleteCourse ($name: String!) {
            deleteCourse (name: $name) {
                name
            }
        }`
    },

    subqueries: {
        itemName: gql`query { allItems { name } }`
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
        states: {start: 0, main: 1, people: 2, items: 3, courses: 4, occupants: 6, participants: 7, checkin: 8, error: 20, done: 21},
        headings: {start: "Dashboard", main: "Dashboard", people: "People", items: "Items", courses: "Courses", occupants: "Occupants", participants: "Participants", checkin: "Check In or Out"},

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
        // eslint-disable-next-line react-hooks/exhaustive-deps
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
            // case state.states.courses       : return (<GraphQLTable sessionid={state.sessionid} details={course_details}/>)
            // case state.states.occupants     : return (<GraphQLTable sessionid={state.sessionid} details={occupancy_details}/>)
            // case state.states.participants  : return (<GraphQLTable sessionid={state.sessionid} details={participancy_details}/>)
            // case state.states.checkin       : window.location = "/checkin?sessionid=" + state.sessionid;
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
        // {key: "courses", text: state.headings.courses, value: "courses"},
        // {key: "occupants", text: state.headings.occupants, value: "occupants"},
        // {key: "participants", text: state.headings.participants, value: "participants"},
        // {content: (<Divider fitted />), value: "divider"},
        // {key: "checkin", text: state.headings.checkin, value: "checkin"}
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
